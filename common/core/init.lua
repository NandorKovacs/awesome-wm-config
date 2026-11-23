-- Shared body of rc.lua. A host's rc.lua calls this module with a table of
-- the settings that differ on that machine; everything else comes from
-- defaults.lua:
--
--   require("common.core") {
--     theme = "gtk",
--     terminal = "konsole",
--   }
--
-- The sections are the folds of the stock rc.lua, one file each. A host that
-- needs another order, or wants to leave one out, can call them itself.

local awful = require("awful")
require("awful.autofocus")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

local defaults = require("common.core.defaults")

return function(host)
  local cfg = {}
  for k, v in pairs(defaults) do
    cfg[k] = v
  end
  for k, v in pairs(host or {}) do
    cfg[k] = v
  end

  if cfg.auto_dpi then
    awful.screen.set_auto_dpi_enabled(true)
  end

  -- what the sections hand to each other: mainmenu, launcher
  local ctx = { settings = cfg }

  require("common.core.errors")(cfg, ctx)
  require("common.core.theme")(cfg, ctx)
  require("common.core.menu")(cfg, ctx)
  require("common.core.wibar")(cfg, ctx)
  require("common.core.keys")(cfg, ctx)
  require("common.core.rules")(cfg, ctx)
  require("common.core.signals")(cfg, ctx)

  for _, cmd in ipairs(cfg.autostart) do
    awful.spawn(cmd)
  end

  if cfg.after then
    cfg.after(ctx)
  end

  return ctx
end
