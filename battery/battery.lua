local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")
local function worker(widget, stdout)
  local percent = stdout:match("%d+%%")
  local color = "#7e5edc"
  if stdout:find("Discharging") then
    local percentnum = tonumber(percent:match("%d+"))
    if percentnum < 15 then
      color = "#c3512a"
      if (percentnum < 6) then
        naughty.notify({title="Low Battery!", text=percent})
      end
    end
  else
    percent = percent .. "🗲"
  end

  beautiful.border_focus = color
  beautiful.border_normal = color
  for _, c in ipairs(client.get()) do
    if c.valid then
      c.border_color = color
    end
  end

  widget:set_text(percent)  
end

return awful.widget.watch('acpi', 15, worker)
