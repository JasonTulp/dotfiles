#!/bin/bash
source "$CONFIG_DIR/plugins/colors.sh"

DEFCOLOR=$TEXT_WHITE
ALERTCOLOR=$TEXT_RED
TOTALSWAP="$(sysctl vm.swapusage | awk '{print $4}')"

pages_active=$(vm_stat | awk '/Pages active/ {print $3}' | sed 's/\.//')
pages_wired=$(vm_stat | awk '/Pages wired down/ {print $4}' | sed 's/\.//')
pages_compressed=$(vm_stat | awk '/Pages occupied by compressor/ {print $5}' | sed 's/\.//')
page_size=$(vm_stat | awk '/page size of/ {print $8}')

# App memory = active + wired + compressed (this matches Activity Monitor)
used_pages=$((pages_active + pages_wired + pages_compressed))

# Convert to GB with 2 decimal places
used_mem_bytes=$((used_pages * page_size))
used_mem_gb=$(echo "scale=2; $used_mem_bytes / 1024 / 1024 / 1024" | bc)

clr="$DEFCOLOR"
# Color alert if using more than 8GB
threshold=50
if (( $(echo "$used_mem_gb > $threshold" | bc -l) )); then
    clr="$ALERTCOLOR"
fi

sketchybar --set "$NAME" label="${used_mem_gb}GB" icon.color="$clr" label.color="$clr"
