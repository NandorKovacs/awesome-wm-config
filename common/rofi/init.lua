-- Shared rofi settings for all rofi-based menus (emoji selector, audio output
-- menu, ...): one theme and one set of common command-line options, so the
-- look is defined in a single place (theme.rasi).

local M = {}

-- directory of this module, with trailing slash
local dir = debug.getinfo(1, "S").source:match("^@(.*/)") or ""

M.config = {
    theme = dir .. "theme.rasi",
    dpi = 96,                 -- bemenu ignores the screen dpi; match it. nil = rofi default
}

-- Customize the configuration
function M.setup(user_config)
    for k, v in pairs(user_config or {}) do
        M.config[k] = v
    end
end

-- Command line shared by every menu, as an argv table starting with "rofi".
-- Callers append their own mode options. No element contains whitespace as
-- long as the theme path does not, so it can also be joined into a string.
function M.command()
    local cmd = { "rofi", "-theme", M.config.theme }
    if M.config.dpi then
        table.insert(cmd, "-dpi")
        table.insert(cmd, tostring(M.config.dpi))
    end
    return cmd
end

return M
