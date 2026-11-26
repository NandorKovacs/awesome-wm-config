-- Media keys (keyboard, Bluetooth AVRCP and USB headset buttons) -> MPRIS and
-- the default audio output, as key rows for common.core.
--
-- Requires playerctl; the volume keys go through common.audio_output.

local awful = require("awful")
local audio_output = require("common.audio_output")

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
  { modifiers = {}, key = "XF86AudioRaiseVolume", on_press = audio_output.volume_up,
    description = "volume up", group = "media" },
  { modifiers = {}, key = "XF86AudioLowerVolume", on_press = audio_output.volume_down,
    description = "volume down", group = "media" },
  { modifiers = {}, key = "XF86AudioMute", on_press = audio_output.toggle_mute,
    description = "mute/unmute", group = "media" },
}
