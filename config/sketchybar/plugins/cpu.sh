#!/bin/bash
source "$CONFIG_DIR/plugins/colors.sh"

# Handle toggle click
if [ "$SENDER" = "mouse.clicked" ]; then
    sketchybar --set "$NAME" label.drawing=toggle
    exit 0
fi

DEFCOLOR=$TEXT_WHITE
ALERTCOLOR=$TEXT_RED

# Get CPU usage using top (user + system)
cpu_line=$(top -l 2 -n 0 -F -s 0 | grep "CPU usage" | tail -1)
cpu_user=$(echo "$cpu_line" | awk '{print $3}' | sed 's/%//')
cpu_sys=$(echo "$cpu_line" | awk '{print $5}' | sed 's/%//')
cpu_used=$(echo "scale=1; $cpu_user + $cpu_sys" | bc)

clr="$DEFCOLOR"
# Color alert if using more than 70% CPU
threshold=70
if (( $(echo "$cpu_used > $threshold" | bc -l) )); then
    clr="$ALERTCOLOR"
fi

sketchybar --set "$NAME" label="${cpu_used} %" icon.color="$clr" label.color="$clr"
