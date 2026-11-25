local awful = require("awful")
local wibox = require("wibox")
local audio_output = require("common.audio_output")

return function(cfg, ctx)
  local modkey = cfg.modkey

  -- Keyboard map indicator and switcher
  local keyboardlayout = awful.widget.keyboardlayout { country_codes = cfg.keyboard_layouts }

  -- Create a textclock widget
  local textclock = wibox.widget.textclock()

  screen.connect_signal("request::desktop_decoration", function(s)
    -- Each screen has its own tag table.
    awful.tag(cfg.tags, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox {
      screen  = s,
      buttons = {
        awful.button({}, 1, function() awful.layout.inc(1) end),
        awful.button({}, 3, function() awful.layout.inc(-1) end),
        awful.button({}, 4, function() awful.layout.inc(1) end),
        awful.button({}, 5, function() awful.layout.inc(-1) end),
      }
    }

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
      screen  = s,
      filter  = awful.widget.taglist.filter.all,
      buttons = {
        awful.button({}, 1, function(t) t:view_only() end),
        awful.button({ modkey }, 1, function(t)
          if client.focus then
            client.focus:move_to_tag(t)
          end
        end),
        awful.button({}, 3, awful.tag.viewtoggle),
        awful.button({ modkey }, 3, function(t)
          if client.focus then
            client.focus:toggle_tag(t)
          end
        end),
        awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
        awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end),
      }
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
      screen  = s,
      filter  = awful.widget.tasklist.filter.currenttags,
      buttons = {
        awful.button({}, 1, function(c)
          c:activate { context = "tasklist", action = "toggle_minimization" }
        end),
        awful.button({}, 3, function() awful.menu.client_list { theme = { width = 250 } } end),
        awful.button({}, 4, function() awful.client.focus.byidx(1) end),
        awful.button({}, 5, function() awful.client.focus.byidx(-1) end),
      }
    }

    -- Right widgets: the host picks and orders them (see defaults.lua)
    local right = cfg.wibar_right(s, {
      pad = wibox.widget.textbox("  "),
      sep = wibox.widget.textbox(" | "),
      audio = audio_output.widget(),
      systray = wibox.widget.systray(),
      keyboard = keyboardlayout,
      clock = textclock,
      layoutbox = s.mylayoutbox,
    })
    right.layout = wibox.layout.fixed.horizontal

    -- Create the wibox
    s.mywibox = awful.wibar {
      position = "top",
      screen   = s,
      widget   = {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
          layout = wibox.layout.fixed.horizontal,
          ctx.launcher,
          s.mytaglist,
          s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        right,
      }
    }
  end)
end
