-- Mouse and key bindings. Keys are rows (see bind.lua) so that a host can
-- add, replace and remove them through the keys and client_keys settings.

local awful = require("awful")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local bind = require("common.core.bind")
local emoji_selector = require("common.emoji_selector")
local audio_output = require("common.audio_output")
local media_keys = require("common.media_keys")

local function global_keys(cfg, ctx)
  local modkey = cfg.modkey
  return {
    -- General Awesome keys
    { modifiers = { modkey }, key = "s", on_press = hotkeys_popup.show_help,
      description = "show help", group = "awesome" },
    { modifiers = { modkey }, key = "w", on_press = function() ctx.mainmenu:show() end,
      description = "show main menu", group = "awesome" },
    { modifiers = { modkey, "Control" }, key = "r", on_press = awesome.restart,
      description = "reload awesome", group = "awesome" },
    { modifiers = { modkey, "Shift" }, key = "q", on_press = awesome.quit,
      description = "quit awesome", group = "awesome" },
    { modifiers = { modkey }, key = "x",
      on_press = function()
        awful.prompt.run {
          prompt       = "Run Lua code: ",
          textbox      = awful.screen.focused().mypromptbox.widget,
          exe_callback = awful.util.eval,
          history_path = awful.util.get_cache_dir() .. "/history_eval"
        }
      end,
      description = "lua execute prompt", group = "awesome" },
    { modifiers = { modkey }, key = "Return", on_press = function() awful.spawn(cfg.terminal) end,
      description = "open a terminal", group = "launcher" },
    { modifiers = { modkey }, key = "r", on_press = function() awful.screen.focused().mypromptbox:run() end,
      description = "run prompt", group = "launcher" },
    { modifiers = { modkey }, key = "p", on_press = function() menubar.show() end,
      description = "show the menubar", group = "launcher" },
    { modifiers = {}, key = "Print", on_press = function() awful.spawn(cfg.screenshot_cmd) end,
      description = "take a screenshot", group = "awesome" },
    { modifiers = { modkey }, key = "BackSpace", on_press = function() awful.spawn(cfg.lock_cmd) end,
      description = "lock screen", group = "awesome" },
    { modifiers = { modkey }, key = "e", on_press = emoji_selector.open,
      description = "select emoji", group = "misc" },
    { modifiers = { modkey }, key = "b", on_press = audio_output.toggle,
      description = "audio output menu", group = "media" },

    -- Tags related keybindings
    { modifiers = { modkey }, key = "Left", on_press = awful.tag.viewprev,
      description = "view previous", group = "tag" },
    { modifiers = { modkey }, key = "Right", on_press = awful.tag.viewnext,
      description = "view next", group = "tag" },
    { modifiers = { modkey }, key = "Escape", on_press = awful.tag.history.restore,
      description = "go back", group = "tag" },

    -- Focus related keybindings
    { modifiers = { modkey }, key = "j", on_press = function() awful.client.focus.byidx(1) end,
      description = "focus next by index", group = "client" },
    { modifiers = { modkey }, key = "k", on_press = function() awful.client.focus.byidx(-1) end,
      description = "focus previous by index", group = "client" },
    { modifiers = { modkey }, key = "Tab",
      on_press = function()
        awful.client.focus.history.previous()
        if client.focus then
          client.focus:raise()
        end
      end,
      description = "go back", group = "client" },
    { modifiers = { modkey, "Control" }, key = "j", on_press = function() awful.screen.focus_relative(1) end,
      description = "focus the next screen", group = "screen" },
    { modifiers = { modkey, "Control" }, key = "k", on_press = function() awful.screen.focus_relative(-1) end,
      description = "focus the previous screen", group = "screen" },
    { modifiers = { modkey, "Control" }, key = "n",
      on_press = function()
        local c = awful.client.restore()
        -- Focus restored client
        if c then
          c:activate { raise = true, context = "key.unminimize" }
        end
      end,
      description = "restore minimized", group = "client" },

    -- Layout related keybindings
    { modifiers = { modkey, "Shift" }, key = "j", on_press = function() awful.client.swap.byidx(1) end,
      description = "swap with next client by index", group = "client" },
    { modifiers = { modkey, "Shift" }, key = "k", on_press = function() awful.client.swap.byidx(-1) end,
      description = "swap with previous client by index", group = "client" },
    { modifiers = { modkey }, key = "u", on_press = awful.client.urgent.jumpto,
      description = "jump to urgent client", group = "client" },
    { modifiers = { modkey }, key = "l", on_press = function() awful.tag.incmwfact(0.05) end,
      description = "increase master width factor", group = "layout" },
    { modifiers = { modkey }, key = "h", on_press = function() awful.tag.incmwfact(-0.05) end,
      description = "decrease master width factor", group = "layout" },
    { modifiers = { modkey, "Shift" }, key = "h", on_press = function() awful.tag.incnmaster(1, nil, true) end,
      description = "increase the number of master clients", group = "layout" },
    { modifiers = { modkey, "Shift" }, key = "l", on_press = function() awful.tag.incnmaster(-1, nil, true) end,
      description = "decrease the number of master clients", group = "layout" },
    { modifiers = { modkey, "Control" }, key = "h", on_press = function() awful.tag.incncol(1, nil, true) end,
      description = "increase the number of columns", group = "layout" },
    { modifiers = { modkey, "Control" }, key = "l", on_press = function() awful.tag.incncol(-1, nil, true) end,
      description = "decrease the number of columns", group = "layout" },
    { modifiers = { modkey }, key = "space", on_press = function() awful.layout.inc(1) end,
      description = "select next", group = "layout" },
    { modifiers = { modkey, "Shift" }, key = "space", on_press = function() awful.layout.inc(-1) end,
      description = "select previous", group = "layout" },

    -- Bind all key numbers to tags. The numrow keygroup uses keycodes, so it
    -- works on any keyboard layout.
    { modifiers = { modkey }, keygroup = "numrow",
      on_press = function(index)
        local screen = awful.screen.focused()
        local tag = screen.tags[index]
        if tag then
          tag:view_only()
        end
      end,
      description = "only view tag", group = "tag" },
    { modifiers = { modkey, "Control" }, keygroup = "numrow",
      on_press = function(index)
        local screen = awful.screen.focused()
        local tag = screen.tags[index]
        if tag then
          awful.tag.viewtoggle(tag)
        end
      end,
      description = "toggle tag", group = "tag" },
    { modifiers = { modkey, "Shift" }, keygroup = "numrow",
      on_press = function(index)
        if client.focus then
          local tag = client.focus.screen.tags[index]
          if tag then
            client.focus:move_to_tag(tag)
          end
        end
      end,
      description = "move focused client to tag", group = "tag" },
    { modifiers = { modkey, "Control", "Shift" }, keygroup = "numrow",
      on_press = function(index)
        if client.focus then
          local tag = client.focus.screen.tags[index]
          if tag then
            client.focus:toggle_tag(tag)
          end
        end
      end,
      description = "toggle focused client on tag", group = "tag" },
  }
end

local function client_keys(cfg)
  local modkey = cfg.modkey
  return {
    { modifiers = { modkey }, key = "f",
      on_press = function(c)
        c.fullscreen = not c.fullscreen
        c:raise()
      end,
      description = "toggle fullscreen", group = "client" },
    { modifiers = { modkey, "Shift" }, key = "c", on_press = function(c) c:kill() end,
      description = "close", group = "client" },
    { modifiers = { modkey, "Control" }, key = "space", on_press = awful.client.floating.toggle,
      description = "toggle floating", group = "client" },
    { modifiers = { modkey, "Control" }, key = "Return", on_press = function(c) c:swap(awful.client.getmaster()) end,
      description = "move to master", group = "client" },
    { modifiers = { modkey }, key = "o", on_press = function(c) c:move_to_screen() end,
      description = "move to screen", group = "client" },
    { modifiers = { modkey }, key = "t", on_press = function(c) c.ontop = not c.ontop end,
      description = "toggle keep on top", group = "client" },
    { modifiers = { modkey }, key = "n",
      on_press = function(c)
        -- The client currently has the input focus, so it cannot be
        -- minimized, since minimized clients can't have the focus.
        c.minimized = true
      end,
      description = "minimize", group = "client" },
    { modifiers = { modkey }, key = "m",
      on_press = function(c)
        c.maximized = not c.maximized
        c:raise()
      end,
      description = "(un)maximize", group = "client" },
    { modifiers = { modkey, "Control" }, key = "m",
      on_press = function(c)
        c.maximized_vertical = not c.maximized_vertical
        c:raise()
      end,
      description = "(un)maximize vertically", group = "client" },
    { modifiers = { modkey, "Shift" }, key = "m",
      on_press = function(c)
        c.maximized_horizontal = not c.maximized_horizontal
        c:raise()
      end,
      description = "(un)maximize horizontally", group = "client" },
  }
end

return function(cfg, ctx)
  local modkey = cfg.modkey

  -- Mouse bindings
  awful.mouse.append_global_mousebindings({
    awful.button({}, 3, function() ctx.mainmenu:toggle() end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev),
  })

  -- Key bindings: shared rows first, so that the host's rows win
  awful.keyboard.append_global_keybindings(bind.keys(bind.merge(
    global_keys(cfg, ctx),
    media_keys,
    cfg.keys)))

  client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
      awful.button({}, 1, function(c)
        c:activate { context = "mouse_click" }
      end),
      awful.button({ modkey }, 1, function(c)
        c:activate { context = "mouse_click", action = "mouse_move" }
      end),
      awful.button({ modkey }, 3, function(c)
        c:activate { context = "mouse_click", action = "mouse_resize" }
      end),
    })
  end)

  client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings(
      bind.keys(bind.merge(client_keys(cfg), cfg.client_keys)))
  end)
end
