-- Emoji selector: bemoji with rofi as the picker, using the shared rofi look
-- from common.rofi.
--
-- Requires bemoji and rofi.

local awful = require("awful")
local rofi = require("common.rofi")

local M = {}

-- directory of this module, with trailing slash
local dir = debug.getinfo(1, "S").source:match("^@(.*/)") or ""

M.config = {
    prompt = "emoji",
    bemoji_opts = { "-tnc" }, -- -t type the emoji, -n no newline, -c copy to clipboard
    emoji_file = dir .. "emojis.txt",
}

-- Customize the configuration
function M.setup(user_config)
    for k, v in pairs(user_config or {}) do
        M.config[k] = v
    end
end

-- Launch the emoji selector
function M.open()
    local c = M.config
    -- bemoji splits BEMOJI_PICKER_CMD on whitespace, so no argument (including
    -- the theme path) may contain spaces
    -- -sync: read the whole list before showing the window, otherwise it opens
    -- empty and grows a frame later
    local picker = table.concat(rofi.command(), " ") .. " -dmenu -sync -i -p " .. c.prompt
    local cmd = { "env", "BEMOJI_PICKER_CMD=" .. picker, "bemoji" }
    for _, opt in ipairs(c.bemoji_opts) do
        table.insert(cmd, opt)
    end
    table.insert(cmd, "-f")
    table.insert(cmd, c.emoji_file)
    awful.spawn(cmd, false)
end

-- Create a keybinding for the emoji selector
function M.create_keybinding(modifiers, key, description)
    return awful.key(modifiers or { "Mod4" }, key or "e", M.open,
        { description = description or "type emoji", group = "misc" })
end

return M
