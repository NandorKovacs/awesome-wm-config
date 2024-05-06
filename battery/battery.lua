local wibox = require("wibox")
local awful = require("awful")

local function worker(widget, stdout)
  local percent = stdout:match("%d+%%")
  
  if stdout:find("Discharging") then
  else
    percent = percent .. "🗲"
  end
  widget:set_text(percent)  
end

return awful.widget.watch('acpi', 15, worker)
