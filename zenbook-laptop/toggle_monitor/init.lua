local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")

local M = {}

-- Configuration
local MONITOR = "eDP-2"
local SCRIPT_PATH = gears.filesystem.get_configuration_dir() .. "toggle_monitor/toggle.sh"
local CHECK_SCRIPT_PATH = gears.filesystem.get_configuration_dir() .. "toggle_monitor/check_monitor.sh"
local ON_ICON = gears.filesystem.get_configuration_dir() .. "toggle_monitor/on.svg"
local OFF_ICON = gears.filesystem.get_configuration_dir() .. "toggle_monitor/off.svg"

-- Create the imagebox widget
local monitor_widget = wibox.widget {
    image = OFF_ICON,
    widget = wibox.widget.imagebox,
    -- forced_width = 50,
    -- forced_height = 30,
}

-- Function to update the icon based on monitor state
local function update_icon()
    awful.spawn.easy_async(CHECK_SCRIPT_PATH, function(stdout, stderr, exitreason, exitcode)
        if exitcode == 0 then
            monitor_widget:set_image(ON_ICON)
        else
            monitor_widget:set_image(OFF_ICON)
        end
    end)
end

-- Function to toggle the monitor
function M.toggle()
    -- Execute the toggle script
    awful.spawn.easy_async(SCRIPT_PATH, function(stdout, stderr, exitreason, exitcode)
        -- Wait a bit for xrandr to update, then check state
        gears.timer {
            timeout = 0.1,
            autostart = true,
            single_shot = true,
            callback = function()
                update_icon()
            end
        }
    end)
end

-- Add button bindings to make the widget clickable
monitor_widget:buttons(gears.table.join(
    awful.button({}, 1, function() M.toggle() end)
))

-- Initialize the icon on startup
update_icon()

-- Return the widget and toggle function
M.widget = monitor_widget
M.update = update_icon

return M

