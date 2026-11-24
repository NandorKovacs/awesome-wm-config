-- Screen brightness through logind, which lets the active session set it
-- without root or group membership.
--
-- Requires busctl (systemd).

local awful = require("awful")

local M = {}

M.config = {
    -- names in /sys/class/backlight, changed together; missing ones are skipped
    devices = { "intel_backlight" },
    step = 5,                 -- levels are the multiples of this, in percent of the maximum
    min = 1,                  -- lower limit in percent; 0 turns an OLED panel black
}

-- device -> { value = newest value asked for, calls = busctl calls still running }
--
-- A held key repeats faster than busctl gets a value into /sys, so while a
-- call is running the next step starts from the value asked for instead.
local pending = {}

-- Customize the configuration
function M.setup(user_config)
    for k, v in pairs(user_config or {}) do
        M.config[k] = v
    end
end

local function read_number(path)
    local f = io.open(path)
    if not f then return end
    local n = f:read("*n")
    f:close()
    return n
end

-- device value of a level in percent
local function to_value(percent, max)
    return math.floor(max * percent / 100 + 0.5)
end

-- The level above or below `current`. A value between two levels, e.g. the
-- lower limit, goes to the nearest one in that direction.
local function next_value(current, max, direction)
    local c = M.config
    local level = current * 100 / max / c.step
    local nearest = math.floor(level + 0.5)
    if to_value(nearest * c.step, max) == current then
        level = nearest + direction
    elseif direction > 0 then
        level = math.floor(level) + 1
    else
        level = math.ceil(level) - 1
    end
    local value = to_value(level * c.step, max)
    if value == current then
        value = current + direction   -- a range too short for the step
    end
    -- a short range rounds a small lower limit down to 0
    local low = math.max(to_value(c.min, max), c.min > 0 and 1 or 0)
    return math.max(low, math.min(max, value))
end

local function set(device, value)
    local call = pending[device] or { calls = 0 }
    pending[device] = call
    call.value = value
    call.calls = call.calls + 1

    local function done()
        call.calls = call.calls - 1
        if call.calls == 0 and pending[device] == call then
            pending[device] = nil
        end
    end
    local pid = awful.spawn.with_line_callback({
        "busctl", "call", "org.freedesktop.login1",
        "/org/freedesktop/login1/session/auto", "org.freedesktop.login1.Session",
        "SetBrightness", "ssu", "backlight", device, string.format("%d", value),
    }, { exit = done })
    if type(pid) ~= "number" then
        done()                -- busctl could not be started
    end
end

local function change(direction)
    for _, device in ipairs(M.config.devices) do
        local sys = "/sys/class/backlight/" .. device .. "/"
        local max = read_number(sys .. "max_brightness")
        local current = pending[device] and pending[device].value or read_number(sys .. "brightness")
        if max and max > 0 and current then
            local value = next_value(current, max, direction)
            if value ~= current then
                set(device, value)
            end
        end
    end
end

function M.up()
    change(1)
end

function M.down()
    change(-1)
end

return M
