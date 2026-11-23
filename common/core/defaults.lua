-- Every setting of the shared rc (see init.lua) with its shared value. A
-- host's rc.lua passes a table holding only the ones that differ there.

local awful = require("awful")

return {
  -- Usually, Mod4 is the key with a logo between Control and Alt.
  modkey = "Mod4",

  -- Name of a theme shipped with awesome, or the path of a theme.lua.
  theme = "default",
  terminal = "xterm",
  editor = os.getenv("EDITOR") or "vim",

  auto_dpi = false,                       -- awful.screen.set_auto_dpi_enabled
  lock_cmd = "xsecurelock",               -- Mod+BackSpace
  screenshot_cmd = "flameshot gui",       -- Print
  media_keys = false,                     -- bind the keys of common/media_keys.lua
  new_clients_as_slave = false,           -- new clients go to the end instead of becoming master

  -- Table of layouts to cover with awful.layout.inc, order matters. The first
  -- one is the layout of every tag at startup.
  layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    awful.layout.suit.floating,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
  },
  tags = { "1", "2", "3", "4", "5", "6", "7", "8", "9" },

  -- function(s) returning the wallpaper of screen s; nil = the theme's
  wallpaper = nil,
  wallpaper_ignore_aspect = false,

  -- Right side of the wibar, in order. w holds the shared widgets built for
  -- screen s: pad, sep, audio, systray, keyboard, clock, layoutbox.
  wibar_right = function(s, w)
    return { w.pad, w.audio, w.sep, w.systray, w.sep, w.keyboard, w.clock, w.layoutbox }
  end,

  -- Key rows, { modifiers, key, press, data }, added to the shared ones. A
  -- row with the modifiers and key of a shared binding replaces it; press =
  -- false removes it. See bind.lua.
  keys = {},
  client_keys = {},

  rules = {},                             -- appended to the shared awful.rules
  autostart = {},                         -- commands spawned after startup

  -- function(ctx) run after everything else; ctx.settings is the merged
  -- settings table, ctx.mainmenu the main menu.
  after = nil,
}
