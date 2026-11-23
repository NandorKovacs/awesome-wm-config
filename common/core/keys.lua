-- Mouse and key bindings. Keys are rows (see bind.lua) so that a host can
-- add, replace and remove them through the keys and client_keys settings.

local gears = require("gears")
local awful = require("awful")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local bind = require("common.core.bind")
local emoji_selector = require("common.emoji_selector")
local audio_output = require("common.audio_output")

local function global_keys(cfg, ctx)
  local modkey = cfg.modkey
  local rows = {
    { { modkey, }, "s", hotkeys_popup.show_help,
      { description = "show help", group = "awesome" } },
    { { modkey, }, "Left", awful.tag.viewprev,
      { description = "view previous", group = "tag" } },
    { { modkey, }, "Right", awful.tag.viewnext,
      { description = "view next", group = "tag" } },
    { { modkey, }, "Escape", awful.tag.history.restore,
      { description = "go back", group = "tag" } },

    { { modkey, }, "j",
      function()
        awful.client.focus.byidx(1)
      end,
      { description = "focus next by index", group = "client" }
    },
    { { modkey, }, "k",
      function()
        awful.client.focus.byidx(-1)
      end,
      { description = "focus previous by index", group = "client" }
    },
    { { modkey, }, "w", function() ctx.mainmenu:show() end,
      { description = "show main menu", group = "awesome" } },

    -- Layout manipulation
    { { modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
      { description = "swap with next client by index", group = "client" } },
    { { modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
      { description = "swap with previous client by index", group = "client" } },
    { { modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end,
      { description = "focus the next screen", group = "screen" } },
    { { modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
      { description = "focus the previous screen", group = "screen" } },
    { { modkey, }, "u", awful.client.urgent.jumpto,
      { description = "jump to urgent client", group = "client" } },
    { { modkey, }, "Tab",
      function()
        awful.client.focus.history.previous()
        if client.focus then
          client.focus:raise()
        end
      end,
      { description = "go back", group = "client" } },

    -- Standard program
    { { modkey, }, "Return", function() awful.spawn(cfg.terminal) end,
      { description = "open a terminal", group = "launcher" } },
    { { modkey, "Control" }, "r", awesome.restart,
      { description = "reload awesome", group = "awesome" } },
    { { modkey, "Shift" }, "q", awesome.quit,
      { description = "quit awesome", group = "awesome" } },
    { { modkey, }, "l", function() awful.tag.incmwfact(0.05) end,
      { description = "increase master width factor", group = "layout" } },
    { { modkey, }, "h", function() awful.tag.incmwfact(-0.05) end,
      { description = "decrease master width factor", group = "layout" } },
    { { modkey, "Shift" }, "h", function() awful.tag.incnmaster(1, nil, true) end,
      { description = "increase the number of master clients", group = "layout" } },
    { { modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1, nil, true) end,
      { description = "decrease the number of master clients", group = "layout" } },
    { { modkey, "Control" }, "h", function() awful.tag.incncol(1, nil, true) end,
      { description = "increase the number of columns", group = "layout" } },
    { { modkey, "Control" }, "l", function() awful.tag.incncol(-1, nil, true) end,
      { description = "decrease the number of columns", group = "layout" } },
    { { modkey, }, "space", function() awful.layout.inc(1) end,
      { description = "select next", group = "layout" } },
    { { modkey, "Shift" }, "space", function() awful.layout.inc(-1) end,
      { description = "select previous", group = "layout" } },

    { { modkey, "Control" }, "n",
      function()
        local c = awful.client.restore()
        -- Focus restored client
        if c then
          c:emit_signal(
            "request::activate", "key.unminimize", { raise = true }
          )
        end
      end,
      { description = "restore minimized", group = "client" } },

    -- Prompt
    { { modkey }, "r", function() awful.screen.focused().mypromptbox:run() end,
      { description = "run prompt", group = "launcher" } },

    { { modkey }, "x",
      function()
        awful.prompt.run {
          prompt       = "Run Lua code: ",
          textbox      = awful.screen.focused().mypromptbox.widget,
          exe_callback = awful.util.eval,
          history_path = awful.util.get_cache_dir() .. "/history_eval"
        }
      end,
      { description = "lua execute prompt", group = "awesome" } },
    -- Menubar
    { { modkey }, "p", function() menubar.show() end,
      { description = "show the menubar", group = "launcher" } },
    { {}, "Print", function() awful.spawn(cfg.screenshot_cmd) end,
      { description = "take a screenshot", group = "awesome" } },
    { { modkey, }, "BackSpace", function() awful.spawn(cfg.lock_cmd) end,
      { description = "lock screen", group = "awesome" } },
    { { modkey }, "e", emoji_selector.open,
      { description = "select emoji", group = "misc" } },
    { { modkey }, "b", audio_output.toggle,
      { description = "audio output menu", group = "media" } },
  }

  -- Bind all key numbers to tags.
  -- Be careful: we use keycodes to make it work on any keyboard layout.
  -- This should map on the top row of your keyboard, usually 1 to 9.
  for i = 1, 9 do
    -- View tag only.
    table.insert(rows, { { modkey }, "#" .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          tag:view_only()
        end
      end,
      { description = "view tag #" .. i, group = "tag" } })
    -- Toggle tag display.
    table.insert(rows, { { modkey, "Control" }, "#" .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          awful.tag.viewtoggle(tag)
        end
      end,
      { description = "toggle tag #" .. i, group = "tag" } })
    -- Move client to tag.
    table.insert(rows, { { modkey, "Shift" }, "#" .. i + 9,
      function()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:move_to_tag(tag)
          end
        end
      end,
      { description = "move focused client to tag #" .. i, group = "tag" } })
    -- Toggle tag on focused client.
    table.insert(rows, { { modkey, "Control", "Shift" }, "#" .. i + 9,
      function()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:toggle_tag(tag)
          end
        end
      end,
      { description = "toggle focused client on tag #" .. i, group = "tag" } })
  end

  return rows
end

local function client_keys(cfg)
  local modkey = cfg.modkey
  return {
    { { modkey, }, "f",
      function(c)
        c.fullscreen = not c.fullscreen
        c:raise()
      end,
      { description = "toggle fullscreen", group = "client" } },
    { { modkey, "Shift" }, "c", function(c) c:kill() end,
      { description = "close", group = "client" } },
    { { modkey, "Control" }, "space", awful.client.floating.toggle,
      { description = "toggle floating", group = "client" } },
    { { modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
      { description = "move to master", group = "client" } },
    { { modkey, }, "o", function(c) c:move_to_screen() end,
      { description = "move to screen", group = "client" } },
    { { modkey, }, "t", function(c) c.ontop = not c.ontop end,
      { description = "toggle keep on top", group = "client" } },
    { { modkey, }, "n",
      function(c)
        -- The client currently has the input focus, so it cannot be
        -- minimized, since minimized clients can't have the focus.
        c.minimized = true
      end,
      { description = "minimize", group = "client" } },
    { { modkey, }, "m",
      function(c)
        c.maximized = not c.maximized
        c:raise()
      end,
      { description = "(un)maximize", group = "client" } },
    { { modkey, "Control" }, "m",
      function(c)
        c.maximized_vertical = not c.maximized_vertical
        c:raise()
      end,
      { description = "(un)maximize vertically", group = "client" } },
    { { modkey, "Shift" }, "m",
      function(c)
        c.maximized_horizontal = not c.maximized_horizontal
        c:raise()
      end,
      { description = "(un)maximize horizontally", group = "client" } },
  }
end

return function(cfg, ctx)
  local modkey = cfg.modkey

  -- Mouse bindings
  root.buttons(gears.table.join(
    awful.button({}, 3, function() ctx.mainmenu:toggle() end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
  ))

  -- Key bindings: shared rows first, so that the host's rows win
  root.keys(bind.keys(bind.merge(
    global_keys(cfg, ctx),
    cfg.media_keys and require("common.media_keys") or {},
    cfg.keys)))

  ctx.clientkeys = bind.keys(bind.merge(client_keys(cfg), cfg.client_keys))

  ctx.clientbuttons = gears.table.join(
    awful.button({}, 1, function(c)
      c:emit_signal("request::activate", "mouse_click", { raise = true })
    end),
    awful.button({ modkey }, 1, function(c)
      c:emit_signal("request::activate", "mouse_click", { raise = true })
      awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function(c)
      c:emit_signal("request::activate", "mouse_click", { raise = true })
      awful.mouse.client.resize(c)
    end)
  )
end
