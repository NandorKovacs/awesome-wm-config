-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

local audio_output = require("common.audio_output")
local battery = require("common.battery.battery")
local power_profile = require("common.power_profile")
local toggle_monitor = require("toggle_monitor")

audio_output.setup { invert_scroll = true }

-- Only what differs on this machine; the rest is common/core/defaults.lua.
require("common.core") {
  terminal = "kgx",
  lock_cmd = "systemctl suspend",

  wibar_right = function(s, w)
    return {
      w.pad,
      w.systray,
      w.sep,
      w.audio,
      w.sep,
      power_profile.widget(),
      w.sep,
      toggle_monitor.widget,
      w.sep,
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
    -- the MyASUS key of the keyboard, sent by duo-keyd
    { modifiers = {}, key = "XF86Launch2", on_press = power_profile.toggle,
      description = "power profile menu", group = "awesome" },
  },
}
