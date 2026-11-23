-- Media keys (keyboard, Bluetooth AVRCP and USB headset buttons) -> MPRIS and
-- the default audio sink, as key rows for common.core.
--
-- Requires playerctl and wpctl.

local awful = require("awful")

return {
  -- Bluetooth headsets send Play and Pause as separate keys; both toggle.
  { modifiers = {}, key = "XF86AudioPlay",
    on_press = function() awful.spawn("playerctl play-pause", false) end,
    description = "play/pause", group = "media" },
  { modifiers = {}, key = "XF86AudioPause",
    on_press = function() awful.spawn("playerctl play-pause", false) end,
    description = "play/pause", group = "media" },
  { modifiers = {}, key = "XF86AudioNext",
    on_press = function() awful.spawn("playerctl next", false) end,
    description = "next track", group = "media" },
  { modifiers = {}, key = "XF86AudioPrev",
    on_press = function() awful.spawn("playerctl previous", false) end,
    description = "previous track", group = "media" },
  { modifiers = {}, key = "XF86AudioRaiseVolume",
    on_press = function() awful.spawn("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+", false) end,
    description = "volume up", group = "media" },
  { modifiers = {}, key = "XF86AudioLowerVolume",
    on_press = function() awful.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-", false) end,
    description = "volume down", group = "media" },
  { modifiers = {}, key = "XF86AudioMute",
    on_press = function() awful.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", false) end,
    description = "mute/unmute", group = "media" },
}
