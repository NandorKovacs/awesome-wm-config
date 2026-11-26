-- Popup for a level that keys change (brightness, volume): an icon, the level
-- as a bar and in percent, at the bottom of the focused screen. One popup is
-- shared, so the newest level replaces the one shown.
--
-- Colours, font and border are the theme's.

local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")

local M = {}

M.config = {
    timeout = 1.5,            -- seconds the popup stays after the last change
    dimmed_opacity = 0.4,     -- of the bar and the text of a dimmed level
}

local popup                   -- built on first use: the theme is loaded by then
local icon, bar, text

local hide = gears.timer {
    single_shot = true,
    callback = function() popup.visible = false end,
}

-- Customize the configuration
function M.setup(user_config)
    for k, v in pairs(user_config or {}) do
        M.config[k] = v
    end
end

-- bottom centre, a tenth of the screen above its edge
local function place(p)
    local s = p.screen
    awful.placement.bottom(p, { parent = s, offset = { y = -s.geometry.height / 10 } })
end

local function build()
    local dpi = beautiful.xresources.apply_dpi
    icon = wibox.widget {
        forced_width = dpi(20),
        forced_height = dpi(20),
        widget = wibox.widget.imagebox,
    }
    bar = wibox.widget {
        background_color = beautiful.bg_minimize,
        forced_width = dpi(150),
        forced_height = dpi(4),
        widget = wibox.widget.progressbar,
    }
    text = wibox.widget {
        halign = "right",
        forced_width = dpi(32),   -- room for "100%", so the bar does not move
        widget = wibox.widget.textbox,
    }
    popup = awful.popup {
        widget = {
            {
                icon,
                { bar, valign = "center", widget = wibox.container.place },
                text,
                spacing = dpi(8),
                layout = wibox.layout.fixed.horizontal,
            },
            margins = dpi(8),
            widget = wibox.container.margin,
        },
        bg = beautiful.bg_normal,
        fg = beautiful.fg_normal,
        border_width = beautiful.border_width,
        border_color = beautiful.bg_focus,
        ontop = true,
        visible = false,
        type = "notification",
        input_passthrough = true,
        placement = place,
    }
end

-- Show a level: args.icon is the path of an image, args.value the level out
-- of args.max (100 if left out). args.dimmed greys the bar and the text, for
-- a level that is not in effect (a muted output).
function M.show(args)
    if not popup then build() end
    local opacity = args.dimmed and M.config.dimmed_opacity or 1
    icon.image = args.icon
    bar.max_value = args.max or 100
    bar.value = args.value
    bar.color = args.dimmed and beautiful.fg_normal or beautiful.bg_focus
    bar.opacity = opacity
    text.text = string.format("%d%%", math.floor(args.value + 0.5))
    text.opacity = opacity
    popup.screen = awful.screen.focused()
    place(popup)
    popup.visible = true
    hide.timeout = M.config.timeout
    hide:again()
end

return M
