local awful = require("awful")
local wibox = require("wibox")

local p_widget = wibox.widget.textbox("")
awful.spawn.easy_async_with_shell(
  "powerprofilesctl get",
  function(stdout)
    p_widget.text = stdout:gsub("\n", "")
  end
)

p_widget.connect_signal("button::press", 
  function(c) 
    local w = c.find_widgets_result.widget
    local t = w.text
    local new
    if t == "power_saver" then
      new = "balanced"   
    elseif t == "balanced" then
      new = "performance"
    elseif t == "performance" then
      new = "power_saver"
    else
      new = "balanced"
    end
    
    awful.spawn.easy_async_with_shell(
      "powerprofilesctl set " .. new,
      function (stdout)
      end
    )
    
    w.text = new
  end
)

return p_widget
