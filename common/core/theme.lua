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

  -- awesome 4.3 only knows the assignment; newer versions warn about it
  if awful.layout.append_default_layouts then
    awful.layout.append_default_layouts(cfg.layouts)
  else
    awful.layout.layouts = cfg.layouts
  end
end
