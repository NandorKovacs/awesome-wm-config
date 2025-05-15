local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")
local function worker(widget, stdout)
  local percent = stdout:match("%d+%%")
  local purple = "#7e5edc"
  local red = "#c3512a"
  local black = "#000000"
  local low = false
  if stdout:find("Discharging") then
    local percentnum = tonumber(percent:match("%d+"))
    if percentnum < 15 then
      low = true
      if (percentnum < 6) then
        naughty.notify({title="Low Battery!", text=percent})
      end
    end
  else
    percent = percent .. "🗲"
  end

  if low then
    beautiful.border_focus = red
    beautiful.border_normal = red
  else 
    beautiful.border_focus = purple
    beautiful.border_normal = black
  end
  for _, c in ipairs(client.get()) do
    if c.valid then
      c.border_color = beautiful.border_normal
    end
  end
  
  if client.focus then
    client.focus.border_color = beautiful.border_focus
  end
  widget:set_text(percent)  
end

return awful.widget.watch('acpi', 5, worker)
