# Emoji Selector Module

A simple module for AwesomeWM to integrate the bemoji emoji picker, using rofi
as the picker with the shared look from `common/rofi`.

## Prerequisites

- [bemoji](https://github.com/marty-oehme/bemoji) must be installed
- [rofi](https://github.com/davatorium/rofi) must be installed

## Usage

```lua
-- Load the emoji selector module
local emoji_selector = require("common.emoji_selector")

-- Optional: Customize the configuration
emoji_selector.setup({
    bemoji_opts = { "-t" }, -- -t to type the emoji, -c to copy to clipboard
})

-- Add to your key bindings (defaults to Win+e)
emoji_selector.create_keybinding({ modkey }, "e", "type emoji")
```

Colours, font and size are set in `common/rofi/theme.rasi`.

## Configuration Options

| Option | Description | Default |
|--------|-------------|---------|
| prompt | Prompt text shown in the picker | `emoji` |
| bemoji_opts | Command-line options for bemoji, as a table | `{ "-tnc" }` |
| emoji_file | Emoji list passed to bemoji with `-f` | `emojis.txt` in this folder |

## Functions

- `emoji_selector.setup(config)` - Customize the configuration
- `emoji_selector.open()` - Open the emoji selector
- `emoji_selector.create_keybinding(modifiers, key, description)` - Create a keybinding for the emoji selector
