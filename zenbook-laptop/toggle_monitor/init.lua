-- Lower screen of the Zenbook Duo: off while the keyboard is docked on it, on
-- while the keyboard is lifted off, with a wibar icon that shows the state
-- and toggles it on click.
--
-- Nothing is polled: awesome reports screen changes and udev the keyboard.
--
-- Requires xrandr and xinput; following the keyboard also needs libgudev.

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local M = {}

-- directory of this module, with trailing slash
local dir = debug.getinfo(1, "S").source:match("^@(.*/)") or ""

M.config = {
    upper = "eDP-1",          -- xrandr names of the two screens
    lower = "eDP-2",
    follow_keyboard = true,   -- switch the lower screen when the keyboard is docked or lifted
    -- USB id of the docked keyboard; lifted, it is a Bluetooth device
    keyboard = { vendor = "0b05", model = "1b2c" },
    -- xinput name of each screen's touch device
    touch = {
        upper = "ELAN9008:00 04F3:425B",
        lower = "ELAN9009:00 04F3:425A",
    },
}

-- what xinput adds to the name of a touch device for its other devices
local TOUCH_DEVICES = { "", " Stylus stylus", " Stylus eraser" }

local widget = wibox.widget {
    image = dir .. "off.svg",
    widget = wibox.widget.imagebox,
}

local switching = false       -- an xrandr call is running
local wanted                  -- state asked for while it runs
local refreshing = false
local udev                    -- keeps the keyboard listener alive
local docked

-- Customize the configuration
function M.setup(user_config)
    for k, v in pairs(user_config or {}) do
        M.config[k] = v
    end
end

function M.is_on()
    for s in screen do
        if s.outputs[M.config.lower] then return true end
    end
    return false
end

-- Each touch device covers its own screen while both are on, and the whole
-- desktop otherwise.
local function map_touch(both)
    local c = M.config
    for _, side in ipairs({ "upper", "lower" }) do
        for _, suffix in ipairs(TOUCH_DEVICES) do
            local device = c.touch[side] .. suffix
            if both then
                awful.spawn({ "xinput", "map-to-output", device, c[side] }, false)
            else
                awful.spawn({ "xinput", "set-prop", device, "Coordinate Transformation Matrix",
                    "1", "0", "0", "0", "1", "0", "0", "0", "1" }, false)
            end
        end
    end
end

-- Bring the icon and the touch devices in line with the screens. One change
-- raises several signals; they are answered together, once awesome is done
-- with it.
local function refresh()
    if refreshing then return end
    refreshing = true
    gears.timer.delayed_call(function()
        refreshing = false
        local on = M.is_on()
        widget.image = dir .. (on and "on.svg" or "off.svg")
        map_touch(on)
    end)
end

-- Turn the lower screen on or off
function M.set(on)
    if switching then
        wanted = on
        return
    end
    local c = M.config
    local cmd = on and { "xrandr", "--output", c.lower, "--auto", "--below", c.upper }
        or { "xrandr", "--output", c.lower, "--off" }

    local function done()
        switching = false
        if wanted ~= nil then
            local state = wanted
            wanted = nil
            M.set(state)
        end
    end
    switching = true
    local pid = awful.spawn.with_line_callback(cmd, { exit = done })
    if type(pid) ~= "number" then
        done()                -- xrandr could not be started
    end
end

function M.toggle()
    if switching then return end  -- a held key repeats
    M.set(not M.is_on())
end

local function is_keyboard(device)
    local k = M.config.keyboard
    return device:get_property("ID_VENDOR_ID") == k.vendor
        and device:get_property("ID_MODEL_ID") == k.model
end

-- The docked keyboard is a USB device with several hidraw interfaces, each
-- with its own event; the first one counts.
local function watch_keyboard()
    local ok, GUdev = pcall(function() return require("lgi").GUdev end)
    if not ok then return end

    udev = GUdev.Client.new({ "hidraw" })
    docked = false
    for _, device in ipairs(udev:query_by_subsystem("hidraw")) do
        docked = docked or is_keyboard(device)
    end
    udev.on_uevent = function(_, action, device)
        if (action ~= "add" and action ~= "remove") or not is_keyboard(device) then return end
        local now = action == "add"
        if now ~= docked then
            docked = now
            M.set(not docked)
        end
    end

    -- Otherwise the screen stays as it is, so that reloading awesome does
    -- not undo a choice made with the key.
    if docked and M.is_on() then
        M.set(false)
    end
end

local function start()
    screen.connect_signal("added", refresh)
    screen.connect_signal("removed", refresh)
    screen.connect_signal("property::outputs", refresh)
    screen.connect_signal("property::geometry", refresh)
    refresh()
    if M.config.follow_keyboard then
        watch_keyboard()
    end
end

widget:buttons(gears.table.join(
    awful.button({}, 1, M.toggle)
))

-- after rc.lua, which may still call setup
if awesome.startup then
    awesome.connect_signal("startup", start)
else
    start()
end

M.widget = widget

return M
