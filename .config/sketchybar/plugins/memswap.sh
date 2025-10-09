#!/bin/bash
source "$CONFIG_DIR/plugins/colors.sh"

DEFCOLOR=$TEXT_WHITE
ALERTCOLOR=$TEXT_RED
TOTALSWAP="$(sysctl vm.swapusage | awk '{print $4}')"

pages_active=$(vm_stat | awk '/Pages active/ {print $3}' | sed 's/\.//')
pages_inactive=$(vm_stat | awk '/Pages inactive/ {print $3}' | sed 's/\.//')
pages_speculative=$(vm_stat | awk '/Pages speculative/ {print $3}' | sed 's/\.//')
pages_wired=$(vm_stat | awk '/Pages wired down/ {print $4}' | sed 's/\.//')
page_size=$(vm_stat | awk '/page size of/ {print $8}')

used_pages=$((pages_active + pages_inactive + pages_speculative + pages_wired))

used_mem=$((used_pages * page_size / 1024 / 1024))

clr=""
if [ "$used_mem" != "0.00M" ]; then
    clr="$ALERTCOLOR"
else
    clr="$DEFCOLOR"
fi

sketchybar --set "$NAME" label="$used_mem" icon.color="$clr" label.color="$clr"
