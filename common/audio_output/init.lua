-- Audio output switcher: a wibar widget showing the default
-- output and its volume, plus a rofi menu (menu.sh) using the shared rofi
-- look from common.rofi.
--
-- Menu keys: Up/Down select, Left/Right change that output's volume,
-- Alt+m mute, Enter make default, Escape close. Typing filters the list.
--
-- Requires rofi. Colours, font and size live in common/rofi/theme.rasi.

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local rofi = require("common.rofi")

local M = {}

-- directory of this module, with trailing slash
local dir = debug.getinfo(1, "S").source:match("^@(.*/)") or ""

M.config = {
    prompt = "output",
    step = 5,                 -- volume change per key press / scroll step, in percent
    invert_scroll = false,    -- scrolling down on the wibar widget raises the volume
    max_volume = 100,
    bar_cells = 10,
    menu_name_length = 32,    -- max characters of an output name in the menu
    bar_name_length = 28,     -- max characters of the output name shown in the wibar
    script = dir .. "menu.sh",
    key_volume_down = "Left",
    key_volume_up = "Right",
    key_mute = "Alt+m",
}

local sinks = {}              -- { name, description, volume, muted }
local default_name
local bar_widget
local menu_pid

local escape = (gears.string and gears.string.xml_escape) or awful.util.escape

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

local function refresh()
    awful.spawn.easy_async(
        { "sh", "-c", 'echo "DEFAULT $(pactl get-default-sink)"; LC_ALL=C pactl list sinks' },
        function(stdout)
            sinks = parse(stdout)
            update_bar()
        end)
end

local function set_volume(s, volume)
    if not s then return end
    s.volume = math.max(0, math.min(M.config.max_volume, volume))
    awful.spawn({ "pactl", "set-sink-volume", s.name, s.volume .. "%" }, false)
    update_bar()
end

local function toggle_mute(s)
    if not s then return end
    s.muted = not s.muted
    awful.spawn({ "pactl", "set-sink-mute", s.name, s.muted and "1" or "0" }, false)
    update_bar()
end

function M.close()
    if type(menu_pid) == "number" then
        awesome.kill(menu_pid, 15)
    end
    menu_pid = nil
end

function M.open()
    if menu_pid then return end
    local c = M.config
    local cmd = {
        -- settings for menu.sh; env execs rofi, so the pid below is rofi's
        "env",
        "AUDIO_OUTPUT_STEP=" .. c.step,
        "AUDIO_OUTPUT_MAX=" .. c.max_volume,
        "AUDIO_OUTPUT_BAR_CELLS=" .. c.bar_cells,
        "AUDIO_OUTPUT_PROMPT=" .. c.prompt,
        "AUDIO_OUTPUT_NAME_MAX=" .. c.menu_name_length,
    }
    for _, arg in ipairs(rofi.command()) do
        table.insert(cmd, arg)
    end
    for _, arg in ipairs {
        "-show", "audio",
        "-modi", "audio:" .. c.script,
        -- free Left/Right from moving the filter cursor (Ctrl+b / Ctrl+f still do)
        "-kb-move-char-back", "Control+b",
        "-kb-move-char-forward", "Control+f",
        "-kb-custom-1", c.key_volume_down,
        "-kb-custom-2", c.key_volume_up,
        "-kb-custom-3", c.key_mute,
    } do
        table.insert(cmd, arg)
    end
    -- start on the current default output (rows are in `pactl list sinks` order)
    for i, s in ipairs(sinks) do
        if s.name == default_name then
            table.insert(cmd, "-selected-row")
            table.insert(cmd, tostring(i - 1))
        end
    end
    local pid = awful.spawn.easy_async(cmd, function()
        menu_pid = nil
        refresh()
    end)
    -- on failure (rofi not installed) awful.spawn returns an error string
    if type(pid) == "number" then
        menu_pid = pid
    end
end

function M.toggle()
    if menu_pid then M.close() else M.open() end
end

-- Keep in sync with changes made elsewhere (the menu, volume keys, headset
-- buttons, devices appearing and disappearing).
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
    M.close()
end)

-- Customize the configuration
function M.setup(user_config)
    for k, v in pairs(user_config or {}) do
        M.config[k] = v
    end
end

-- Scroll on the wibar widget, direction 1 (up) or -1 (down). Does nothing
-- while the output is muted.
local function scroll(direction)
    local s = default_sink()
    if not s or s.muted then return end
    if M.config.invert_scroll then direction = -direction end
    set_volume(s, s.volume + direction * M.config.step)
end

-- Wibar widget: click opens the menu, right click mutes, scroll changes volume
function M.widget()
    if bar_widget then return bar_widget end
    bar_widget = wibox.widget.textbox("…")
    bar_widget:buttons(gears.table.join(
        awful.button({}, 1, M.toggle),
        awful.button({}, 3, function() toggle_mute(default_sink()) end),
        awful.button({}, 4, function() scroll(1) end),
        awful.button({}, 5, function() scroll(-1) end)))
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
