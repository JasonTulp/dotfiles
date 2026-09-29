#!/bin/bash
source "$CONFIG_DIR/plugins/colors.sh"

# Handle toggle click
if [ "$SENDER" = "mouse.clicked" ]; then
    sketchybar --set "$NAME" label.drawing=toggle
    exit 0
fi

DEFCOLOR=$TEXT_WHITE
ALERTCOLOR=$TEXT_RED

# Get storage info for the root volume
storage_info=$(df -H / | tail -1)
total=$(echo "$storage_info" | awk '{print $2}')
used=$(echo "$storage_info" | awk '{print $3}')
available=$(echo "$storage_info" | awk '{print $4}' | sed 's/G//')
percent_used=$(echo "$storage_info" | awk '{print $5}' | sed 's/%//')

clr="$DEFCOLOR"
# Color alert if using more than 80% storage
threshold=80
if (( $(echo "$percent_used > $threshold" | bc -l) )); then
    clr="$ALERTCOLOR"
fi

sketchybar --set "$NAME" label="${available} GB" icon.color="$clr" label.color="$clr"
