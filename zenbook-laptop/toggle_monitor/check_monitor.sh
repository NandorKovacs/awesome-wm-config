#!/bin/bash

MONITOR="eDP-2"

# Check if the monitor is currently connected and enabled
xrandr | grep "$MONITOR connected" | grep -q '[0-9]x[0-9]'

