local awful = require("awful")
local beautiful = require("beautiful")
local ruled = require("ruled")

-- Rules to apply to new clients, by id.
local function shared_rules()
  return {
    -- All clients will match this rule.
    {
      id = "global",
      rule = {},
      properties = {
        border_width = beautiful.border_width,
        border_color = beautiful.border_normal,
        focus = awful.client.focus.filter,
        raise = true,
        screen = awful.screen.preferred,
        placement = awful.placement.no_overlap + awful.placement.no_offscreen
      }
    },

    -- Floating clients.
    {
      id = "floating",
      rule_any = {
        instance = {
          "DTA",   -- Firefox addon DownThemAll.
          "copyq", -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer" },

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester", -- xev.
        },
        role = {
          "AlarmWindow",   -- Thunderbird's calendar.
          "ConfigManager", -- Thunderbird's about:config.
          "pop-up",        -- e.g. Google Chrome's (detached) Developer Tools.
        }
      },
      properties = { floating = true }
    },

    -- Add titlebars to normal clients and dialogs
    {
      id = "titlebars",
      rule_any = { type = { "normal", "dialog" }
      },
      properties = { titlebars_enabled = true }
    },
  }
end

return function(cfg)
  ruled.client.connect_signal("request::rules", function()
    for _, rule in ipairs(shared_rules()) do
      -- the host's rules setting: <id> = false removes a shared rule,
      -- <id> = { ... } replaces it
      local override = cfg.rules[rule.id]
      if override then
        override.id = rule.id
        ruled.client.append_rule(override)
      elseif override == nil then
        ruled.client.append_rule(rule)
      end
    end

    -- its list part is added
    for _, rule in ipairs(cfg.rules) do
      ruled.client.append_rule(rule)
    end
  end)
end
