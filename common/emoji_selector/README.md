# Emoji Selector Module

A simple module for AwesomeWM to integrate the bemoji emoji picker with customizable options.

## Prerequisites

- [bemoji](https://github.com/marty-oehme/bemoji) must be installed
- [bemenu](https://github.com/Cloudef/bemenu) must be installed

## Usage

1. Add the module to your rc.lua:

```lua
-- Load the emoji selector module
local emoji_selector = require("common.emoji_selector")

-- Optional: Customize the configuration
emoji_selector.setup({
    bemenu_opts = 'BEMENU_OPTS=\'--tf "#your-color" --hf "#your-color" --bdr "#your-color" -l 10 -p emoji -c -W 0.4 -B 4 --fn "Monospace 25"\'',
    bemoji_opts = '-t', -- -t to type the emoji, -c to copy to clipboard
    bemoji_picker_cmd = 'BEMOJI_PICKER_CMD=bemenu'
})

-- Add to your key bindings
local keys = {
    -- Your other keybindings...
    
    -- Add the emoji selector keybinding (defaults to Win+e)
    emoji_selector.create_keybinding({ modkey }, "e", "type emoji")
}
```

## Configuration Options

| Option | Description | Default |
|--------|-------------|---------|
| bemenu_opts | Environment variable with styling options for bemenu | BEMENU_OPTS=\'--tf "#7e5edc" --hf "#7e5edc" --bdr "#7e5edc" -l 10 -p emoji -c -W 0.4 -B 4 --fn "Monospace 25"\' |
| bemoji_opts | Command-line options for bemoji | -t |
| bemoji_picker_cmd | The picker command to use | BEMOJI_PICKER_CMD=bemenu |

## Functions

- `emoji_selector.setup(config)` - Customize the configuration
- `emoji_selector.open()` - Open the emoji selector
- `emoji_selector.create_keybinding(modifiers, key, description)` - Create a keybinding for the emoji selector