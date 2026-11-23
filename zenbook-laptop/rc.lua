-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

local beautiful = require("beautiful")
local battery = require("common.battery.battery")
local toggle_monitor = require("toggle_monitor")

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
    { {}, "F7", function() toggle_monitor.toggle() end,
      { description = "toggle monitor", group = "awesome" } },
  },
}
