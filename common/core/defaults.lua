-- Every setting of the shared rc (see init.lua) with its shared value. A
-- host's rc.lua passes a table holding only the ones that differ there.
--
-- The core uses the awesome-git API (ruled, awful.keyboard, request::*
-- signals) and does not run on awesome 4.3.

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

  -- function(s) returning the wallpaper image of screen s; nil = the theme's
  wallpaper = nil,
  wallpaper_ignore_aspect = false,        -- stretch it to the screen instead of cropping it

  -- Right side of the wibar, in order. w holds the shared widgets built for
  -- screen s: pad, sep, audio, systray, keyboard, clock, layoutbox.
  wibar_right = function(s, w)
    return { w.pad, w.audio, w.sep, w.systray, w.sep, w.keyboard, w.clock, w.layoutbox }
  end,

  -- Key rows (argument tables of awful.key) added to the shared ones. A row
  -- with the modifiers and key of a shared binding replaces it; on_press =
  -- false removes it. See bind.lua.
  keys = {},
  client_keys = {},

  -- Client rules (argument tables of ruled.client.append_rule). The list
  -- part is added to the shared rules; <id> = { ... } replaces the shared
  -- rule with that id (global, floating, titlebars), <id> = false removes it.
  rules = {},
  autostart = {},                         -- commands spawned after startup

  -- function(ctx) run at the end of rc.lua; ctx.settings is the merged
  -- settings table, ctx.mainmenu the main menu.
  after = nil,
}
