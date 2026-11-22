-- Audio output switcher: a wibar widget showing the default output and its
-- volume, plus a keyboard-driven menu styled like the bemenu emoji selector.
--
-- Menu keys: Up/Down select, Left/Right change that output's volume,
-- Space (or m) mute, Enter make default, Escape close.

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local M = {}

M.config = {
    accent = "#7e5edc",       -- title, highlighted row and border (bemenu --tf/--hf/--bdr)
    bg = "#121212",
    fg = "#cacaca",
    dim = "#6b6b6b",
    -- Font sizes are in bemenu's units (points at 96 dpi). awesome scales fonts
    -- by the screen's dpi and bemenu does not, so they are converted on open.
    font_family = "Monospace",
    font_size = 25,           -- bemenu --fn "Monospace 25"
    hint_size = 12,
    width = 0.4,              -- fraction of the screen width, border included (bemenu -W)
    padding = 8,              -- left/right space inside the border, in pixels
    border_width = 4,         -- bemenu -B
    prompt = "output",
    step = 5,                 -- volume change per key press / scroll step, in percent
    max_volume = 100,
    bar_cells = 10,
    bar_name_length = 28,     -- max characters of the output name shown in the wibar
}

local sinks = {}              -- { name, description, volume, muted }
local default_name
local selected = 1
local popup, rows, grabber
local font, hint_font         -- set per screen in M.open
local bar_widget

local escape = (gears.string and gears.string.xml_escape) or awful.util.escape

local function span(color, text)
    return string.format('<span foreground="%s">%s</span>', color, text)
end

local function default_sink()
    for _, s in ipairs(sinks) do
        if s.name == default_name then return s end
    end
end

local function parse(stdout)
    local list, cur = {}, nil
    for line in stdout:gmatch("[^\n]+") do
        local def = line:match("^DEFAULT (.+)$")
        if def then
            default_name = def
        elseif line:match("^Sink #%d+") then
            cur = { volume = 0, muted = false }
            table.insert(list, cur)
        elseif cur then
            local name = line:match("^\tName: (.+)$")
            local desc = line:match("^\tDescription: (.+)$")
            local mute = line:match("^\tMute: (%a+)")
            local vol = line:match("^\tVolume: .-(%d+)%%")
            if name then cur.name = name end
            if desc then cur.description = desc end
            if mute then cur.muted = (mute == "yes") end
            if vol then cur.volume = tonumber(vol) end
        end
    end
    return list
end

local function update_bar()
    if not bar_widget then return end
    local s = default_sink()
    if not s then
        bar_widget.markup = "no output"
        return
    end
    local name = s.description or s.name
    if #name > M.config.bar_name_length then
        name = name:sub(1, M.config.bar_name_length - 1) .. "…"
    end
    local state = s.muted and "muted" or (s.volume .. "%")
    bar_widget.markup = escape(name .. " " .. state)
end

local function volume_bar(s)
    local cells = M.config.bar_cells
    local filled = math.floor(math.min(s.volume, 100) / 100 * cells + 0.5)
    local bar = string.rep("█", filled) .. string.rep("░", cells - filled)
    local label = s.muted and " mute" or string.format(" %3d%%", s.volume)
    return bar .. label
end

local set_default -- forward declaration, used by row clicks

local function render()
    if not popup then return end
    local c = M.config
    rows:reset()
    rows:add(wibox.widget {
        markup = span(c.accent, escape(c.prompt)),
        font = font,
        widget = wibox.widget.textbox,
    })
    -- height of one text line, so long names are cut with "…" instead of wrapping
    local _, line_height = wibox.widget.textbox.get_preferred_size(
        wibox.widget { text = "X", font = font, widget = wibox.widget.textbox }, popup.screen)
    for i, s in ipairs(sinks) do
        local color = (i == selected) and c.accent or (s.muted and c.dim or c.fg)
        -- bemenu indents its entries by the width of the prompt
        local marker = string.rep(" ", #c.prompt - 1) .. ((s.name == default_name) and "● " or "  ")
        local row = wibox.widget {
            nil,
            {
                markup = span(color, escape(marker .. (s.description or s.name))),
                font = font,
                ellipsize = "end",
                forced_height = line_height,
                widget = wibox.widget.textbox,
            },
            {
                markup = span(color, "  " .. volume_bar(s)),
                font = font,
                widget = wibox.widget.textbox,
            },
            layout = wibox.layout.align.horizontal,
        }
        row:buttons(awful.button({}, 1, function()
            selected = i
            set_default()
        end))
        rows:add(row)
    end
    rows:add(wibox.widget {
        markup = span(c.dim, "↑↓ select   ←→ volume   space mute   ⏎ set default   esc close"),
        font = hint_font,
        widget = wibox.widget.textbox,
    })
end

local function refresh()
    awful.spawn.easy_async(
        { "sh", "-c", 'echo "DEFAULT $(pactl get-default-sink)"; LC_ALL=C pactl list sinks' },
        function(stdout)
            local keep = sinks[selected] and sinks[selected].name
            sinks = parse(stdout)
            selected = math.max(1, math.min(selected, #sinks))
            for i, s in ipairs(sinks) do
                if s.name == keep then selected = i end
            end
            update_bar()
            render()
        end)
end

local function set_volume(s, volume)
    if not s then return end
    s.volume = math.max(0, math.min(M.config.max_volume, volume))
    awful.spawn({ "pactl", "set-sink-volume", s.name, s.volume .. "%" }, false)
    update_bar()
    render()
end

local function toggle_mute(s)
    if not s then return end
    s.muted = not s.muted
    awful.spawn({ "pactl", "set-sink-mute", s.name, s.muted and "1" or "0" }, false)
    update_bar()
    render()
end

function M.close()
    if grabber then
        awful.keygrabber.stop(grabber)
        grabber = nil
    end
    if popup then
        popup.visible = false
        popup = nil
    end
end

set_default = function()
    local s = sinks[selected]
    if s then
        default_name = s.name
        awful.spawn({ "pactl", "set-default-sink", s.name }, false)
        update_bar()
    end
    M.close()
end

local function on_key(_, key, event)
    if event ~= "press" then return end
    local s = sinks[selected]
    if key == "Escape" or key == "q" then
        M.close()
    elseif key == "Return" or key == "KP_Enter" then
        set_default()
    elseif key == "Up" or key == "k" then
        selected = (selected - 2) % math.max(#sinks, 1) + 1
        render()
    elseif key == "Down" or key == "j" then
        selected = selected % math.max(#sinks, 1) + 1
        render()
    elseif key == "Left" or key == "h" then
        if s then set_volume(s, s.volume - M.config.step) end
    elseif key == "Right" or key == "l" then
        if s then set_volume(s, s.volume + M.config.step) end
    elseif key == " " or key == "space" or key == "m" then
        toggle_mute(s)
    end
end

function M.open()
    if popup then return end
    local c = M.config
    local screen = awful.screen.focused()
    for i, s in ipairs(sinks) do
        if s.name == default_name then selected = i end
    end
    local scale = 96 / (screen.dpi or 96)
    font = string.format("%s %.2f", c.font_family, c.font_size * scale)
    hint_font = string.format("%s %.2f", c.font_family, c.hint_size * scale)
    rows = wibox.layout.fixed.vertical()
    popup = awful.popup {
        widget = {
            {
                rows,
                strategy = "exact",
                width = math.floor(screen.geometry.width * c.width)
                    - 2 * c.border_width - 2 * c.padding,
                widget = wibox.container.constraint,
            },
            left = c.padding, right = c.padding, bottom = 4,
            widget = wibox.container.margin,
        },
        screen = screen,
        placement = awful.placement.centered,
        ontop = true,
        visible = true,
        bg = c.bg,
        fg = c.fg,
        border_width = c.border_width,
        border_color = c.accent,
    }
    render()
    grabber = awful.keygrabber.run(on_key)
    refresh()
end

function M.toggle()
    if popup then M.close() else M.open() end
end

-- Keep in sync with changes made elsewhere (volume keys, headset buttons,
-- devices appearing and disappearing).
local refresh_soon = gears.timer {
    timeout = 0.15,
    single_shot = true,
    callback = refresh,
}

local subscribe_pid
local function subscribe()
    subscribe_pid = awful.spawn.with_line_callback(
        { "sh", "-c", "LC_ALL=C exec pactl subscribe" },
        {
            stdout = function(line)
                if line:match(" on sink #") or line:match(" on server") or line:match(" on card") then
                    refresh_soon:again()
                end
            end,
            exit = function()
                subscribe_pid = nil
                gears.timer.start_new(5, function()
                    subscribe()
                    refresh()
                    return false
                end)
            end,
        })
end

awesome.connect_signal("exit", function()
    if type(subscribe_pid) == "number" then
        awesome.kill(subscribe_pid, 15)
    end
end)

-- Customize the configuration
function M.setup(user_config)
    for k, v in pairs(user_config or {}) do
        M.config[k] = v
    end
end

-- Wibar widget: click opens the menu, right click mutes, scroll changes volume
function M.widget()
    if bar_widget then return bar_widget end
    bar_widget = wibox.widget.textbox("…")
    bar_widget:buttons(gears.table.join(
        awful.button({}, 1, M.toggle),
        awful.button({}, 3, function() toggle_mute(default_sink()) end),
        awful.button({}, 4, function()
            local s = default_sink()
            if s then set_volume(s, s.volume + M.config.step) end
        end),
        awful.button({}, 5, function()
            local s = default_sink()
            if s then set_volume(s, s.volume - M.config.step) end
        end)))
    subscribe()
    refresh()
    return bar_widget
end

-- Create a keybinding that opens the menu
function M.create_keybinding(modifiers, key, description)
    return awful.key(modifiers or { "Mod4" }, key or "a", M.toggle,
        { description = description or "audio output menu", group = "media" })
end

return M
