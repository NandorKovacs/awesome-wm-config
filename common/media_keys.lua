-- Media keys (keyboard, Bluetooth AVRCP and USB headset buttons) -> MPRIS and
-- the default audio sink, as key rows for common.core (media_keys = true).
--
-- Requires playerctl and wpctl.

local awful = require("awful")

return {
  -- Bluetooth headsets send Play and Pause as separate keys; both toggle.
  { {}, "XF86AudioPlay", function() awful.spawn("playerctl play-pause", false) end,
    { description = "play/pause", group = "media" } },
  { {}, "XF86AudioPause", function() awful.spawn("playerctl play-pause", false) end,
    { description = "play/pause", group = "media" } },
  { {}, "XF86AudioNext", function() awful.spawn("playerctl next", false) end,
    { description = "next track", group = "media" } },
  { {}, "XF86AudioPrev", function() awful.spawn("playerctl previous", false) end,
    { description = "previous track", group = "media" } },
  { {}, "XF86AudioRaiseVolume",
    function() awful.spawn("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+", false) end,
    { description = "volume up", group = "media" } },
  { {}, "XF86AudioLowerVolume",
    function() awful.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-", false) end,
    { description = "volume down", group = "media" } },
  { {}, "XF86AudioMute",
    function() awful.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", false) end,
    { description = "mute/unmute", group = "media" } },
}
