local wibox = require("wibox")
local awful = require("awful")
local res = wibox.widget.textbox()
res.text = "you are great"

local function worker(widget, stdout)
  local percent = stdout:match("%d%d%%")
  widget:set_text(percent)  
end

return awful.widget.watch('acpi', 15, worker)
