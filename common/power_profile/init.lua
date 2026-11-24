-- Power profile switcher: a wibar icon showing the active profile of
-- power-profiles-daemon, plus a rofi menu (menu.sh) using the shared rofi
-- look from common.rofi.
--
-- Menu keys: Up/Down select, Enter switch to that profile, Escape close.
-- Typing filters the list.
--
-- Requires power-profiles-daemon (powerprofilesctl), gdbus (glib2) and rofi.
-- The icons are Material Symbols: eco, balance and bolt.

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local rofi = require("common.rofi")

local M = {}

-- directory of this module, with trailing slash
local dir = debug.getinfo(1, "S").source:match("^@(.*/)") or ""

M.config = {
    prompt = "power",
    -- from saving to fast: the order of the menu rows
    profiles = { "power-saver", "balanced", "performance" },
    icons = {
        ["power-saver"] = dir .. "eco.svg",
        balanced = dir .. "balance.svg",
        performance = dir .. "bolt.svg",
    },
    script = dir .. "menu.sh",
}

local profiles = {}           -- the profiles this machine has, in the order of the config
local active
local bar_widget
local menu_pid

local function parse(stdout)
    local available = {}
    active = nil
    for line in stdout:gmatch("[^\n]+") do
        local mark, name = line:match("^([* ]) ([%w-]+):$")
        if name then
            available[name] = true
            if mark == "*" then active = name end
        end
    end
    local list = {}
    for _, name in ipairs(M.config.profiles) do
        if available[name] then table.insert(list, name) end
    end
    return list
end

-- No icon while the daemon cannot be asked.
local function update_bar()
    if not bar_widget then return end
    bar_widget.image = active and M.config.icons[active] or nil
end

local function refresh()
    awful.spawn.easy_async({ "powerprofilesctl", "list" }, function(stdout)
        profiles = parse(stdout)
        update_bar()
    end)
end

-- Keep in sync with changes made elsewhere (the menu, other tools, the
-- daemon starting).
local refresh_soon = gears.timer {
    timeout = 0.15,
    single_shot = true,
    callback = refresh,
}

function M.close()
    if type(menu_pid) == "number" then
        awesome.kill(menu_pid, 15)
    end
    menu_pid = nil
end

function M.open()
    if menu_pid then return end
    local c = M.config
    local cmd = {
        -- settings for menu.sh; env execs rofi, so the pid below is rofi's
        "env",
        "POWER_PROFILE_PROMPT=" .. c.prompt,
        "POWER_PROFILE_ORDER=" .. table.concat(c.profiles, " "),
    }
    for _, arg in ipairs(rofi.command()) do
        table.insert(cmd, arg)
    end
    for _, arg in ipairs {
        "-show", "power",
        "-modi", "power:" .. c.script,
    } do
        table.insert(cmd, arg)
    end
    -- start on the active profile (rows are in the order of `profiles`)
    for i, name in ipairs(profiles) do
        if name == active then
            table.insert(cmd, "-selected-row")
            table.insert(cmd, tostring(i - 1))
        end
    end
    local pid = awful.spawn.easy_async(cmd, function()
        menu_pid = nil
        refresh()
    end)
    -- on failure (rofi not installed) awful.spawn returns an error string
    if type(pid) == "number" then
        menu_pid = pid
    end
end

function M.toggle()
    if menu_pid then M.close() else M.open() end
end

local monitor_pid
local function monitor()
    monitor_pid = awful.spawn.with_line_callback(
        { "gdbus", "monitor", "--system", "--dest", "net.hadess.PowerProfiles",
          "--object-path", "/net/hadess/PowerProfiles" },
        {
            -- a changed property, or the daemon appearing or going away
            stdout = function()
                refresh_soon:again()
            end,
            exit = function()
                monitor_pid = nil
                gears.timer.start_new(5, function()
                    monitor()
                    refresh()
                    return false
                end)
            end,
        })
end

awesome.connect_signal("exit", function()
    if type(monitor_pid) == "number" then
        awesome.kill(monitor_pid, 15)
    end
    M.close()
end)

-- Customize the configuration
function M.setup(user_config)
    for k, v in pairs(user_config or {}) do
        M.config[k] = v
    end
end

-- Wibar widget: click opens the menu
function M.widget()
    if bar_widget then return bar_widget end
    bar_widget = wibox.widget.imagebox()
    bar_widget:buttons(gears.table.join(
        awful.button({}, 1, M.toggle)))
    monitor()
    refresh()
    return bar_widget
end

-- Create a keybinding that opens the menu
function M.create_keybinding(modifiers, key, description)
    return awful.key(modifiers or { "Mod4", "Shift" }, key or "b", M.toggle,
        { description = description or "power profile menu", group = "awesome" })
end

return M
