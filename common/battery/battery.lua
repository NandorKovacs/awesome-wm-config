local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")
local function worker(widget, stdout)
  local status, percentnum
  for line in stdout:gmatch("[^\r\n]+") do
    local s, p = line:match("^BAT%d+ (%a[%a ]-) (%d+)$")
    if s then
      status, percentnum = s, tonumber(p)
      break
    end
  end
  if not status then return end
  local percent = percentnum .. "%"
  local purple = "#7e5edc"
  local red = "#c3512a"
  local black = "#000000"
  local low = false
  if status == "Discharging" then
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

-- read sysfs instead of acpi: phantom HID batteries (e.g. ELAN touchscreens)
-- pollute acpi output indistinguishably, but real batteries are named BAT*
return awful.widget.watch({'sh', '-c',
  'for b in /sys/class/power_supply/BAT*; do printf "%s %s %s\\n" "${b##*/}" "$(cat "$b/status")" "$(cat "$b/capacity")"; done'},
  5, worker)
