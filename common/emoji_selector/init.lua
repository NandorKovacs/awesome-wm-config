local awful = require("awful")

local M = {}

-- Default configuration for the emoji selector
M.config = {
    bemenu_opts = 'BEMENU_OPTS=\'--tf "#7e5edc" --hf "#7e5edc" --bdr "#7e5edc" -l 10 -p emoji -c -W 0.4 -B 4 --fn "Monospace 25"\'',
    bemoji_opts = '-t -f ~/.config/awesome/common/emoji_selector/emojis.txt',
    bemoji_picker_cmd = 'BEMOJI_PICKER_CMD=bemenu'
}

-- Initialize emoji selector with custom configuration
function M.setup(user_config)
    if user_config then
        for k, v in pairs(user_config) do
            M.config[k] = v
        end
    end
end

-- Launch emoji selector
function M.open()
    local cmd = string.format("%s %s bemoji %s", 
        M.config.bemenu_opts, 
        M.config.bemoji_picker_cmd, 
        M.config.bemoji_opts)
    
    awful.spawn.with_shell(cmd)
end

-- Create a keybinding for the emoji selector
function M.create_keybinding(modifiers, key, description)
    description = description or "type emoji"
    modifiers = modifiers or { "Mod4" }
    key = key or "e"
    
    return awful.key(
        modifiers, key, 
        function() M.open() end, 
        { description = description, group = "misc" }
    )
end

return M
