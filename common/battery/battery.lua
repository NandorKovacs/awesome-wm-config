local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")
local was_low
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
  local red = "#e05561"
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

  -- the other highlights of the focused client; nil is the theme's colour.
  -- Not the taglist: red there would clash with the urgent tags
  if low ~= was_low then
    was_low = low
    local highlight = low and red or nil
    beautiful.tasklist_bg_focus = highlight
    beautiful.titlebar_bg_focus = highlight
    -- nothing redraws these when the theme changes, so emit what they listen to
    if client.focus then
      client.focus:emit_signal("property::active")
    end
  end
  widget:set_text(percent)  
end

-- read sysfs instead of acpi: phantom HID batteries (e.g. ELAN touchscreens)
-- pollute acpi output indistinguishably, but real batteries are named BAT*
return awful.widget.watch({'sh', '-c',
  'for b in /sys/class/power_supply/BAT*; do printf "%s %s %s\\n" "${b##*/}" "$(cat "$b/status")" "$(cat "$b/capacity")"; done'},
  5, worker)
