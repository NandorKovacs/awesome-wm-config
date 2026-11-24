-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

local beautiful = require("beautiful")
local audio_output = require("common.audio_output")
local battery = require("common.battery.battery")
local toggle_monitor = require("toggle_monitor")

audio_output.setup { invert_scroll = true }

-- Only what differs on this machine; the rest is common/core/defaults.lua.
require("common.core") {
  theme = "xresources",
  terminal = "kgx",
  lock_cmd = "systemctl suspend",

  wallpaper = function(s)
    local wallpaper = beautiful.wallpaper
    if type(wallpaper) == "function" then
      return wallpaper(s)
    end
    local theme_assets = require("beautiful.theme_assets")
    return theme_assets.wallpaper(
      "#465457",
      "#888a85",
      "#7e5edc",
      s
    )
  end,

  wibar_right = function(s, w)
    return {
      w.pad,
      w.audio,
      w.sep,
      w.systray,
      w.sep,
      toggle_monitor.widget,
      battery,
      w.keyboard,
      w.clock,
      w.layoutbox,
    }
  end,

  keys = {
    -- the lower display key of the keyboard, sent by duo-keyd
    { modifiers = {}, key = "XF86Display", on_press = function() toggle_monitor.toggle() end,
      description = "toggle monitor", group = "awesome" },
    -- Fn+F7: a plain key, so it also works without duo-keyd (over Bluetooth)
    { modifiers = {}, key = "F7", on_press = function() toggle_monitor.toggle() end,
      description = "toggle monitor", group = "awesome" },
  },
}
