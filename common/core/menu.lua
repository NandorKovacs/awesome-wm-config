local awful = require("awful")
local beautiful = require("beautiful")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

return function(cfg, ctx)
  local editor_cmd = cfg.terminal .. " -e " .. cfg.editor

  -- Create a launcher widget and a main menu
  local awesomemenu = {
    { "hotkeys",     function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "manual",      cfg.terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart",     awesome.restart },
    { "quit",        function() awesome.quit() end },
  }

  ctx.mainmenu = awful.menu({
    items = { { "awesome", awesomemenu, beautiful.awesome_icon },
      { "open terminal", cfg.terminal }
    }
  })

  ctx.launcher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu = ctx.mainmenu
  })

  -- Menubar configuration
  menubar.utils.terminal = cfg.terminal -- Set the terminal for applications that require it
end
