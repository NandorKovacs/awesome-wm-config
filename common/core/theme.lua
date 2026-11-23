local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")

return function(cfg)
  -- Themes define colours, icons, font and wallpapers.
  local theme = cfg.theme
  if not theme:find("/") then
    theme = gears.filesystem.get_themes_dir() .. theme .. "/theme.lua"
  end
  beautiful.init(theme)

  -- Table of layouts to cover with awful.layout.inc, order matters.
  tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts(cfg.layouts)
  end)

  -- Also emitted when a screen's geometry changes (e.g. different resolution)
  screen.connect_signal("request::wallpaper", function(s)
    local wallpaper = cfg.wallpaper or beautiful.wallpaper
    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    -- not awful.wallpaper: its imagebox cannot draw the recording surfaces
    -- that the themes generate
    if wallpaper then
      gears.wallpaper.maximized(wallpaper, s, cfg.wallpaper_ignore_aspect)
    end
  end)
end
