#!/bin/bash

MONITOR="eDP-2"
PRIMARY="eDP-1"  # Your main display (usually the laptop screen)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if the monitor is currently connected and enabled
if "$SCRIPT_DIR/check_monitor.sh"; then
    # It's on — turn it off
    xrandr --output "$MONITOR" --off
else
    # It's off — turn it on and position it
    xrandr --output "$MONITOR" --auto --below "$PRIMARY"
fi

