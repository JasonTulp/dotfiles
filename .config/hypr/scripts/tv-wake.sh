#!/usr/bin/env bash
# Make sure the TV is really lit before anything is put on it.
#
# Hyprland can list the monitor at full resolution while the kernel never gave
# it a display head — the GPU runs out of heads if the centre monitor claimed
# 144Hz first, and the output then shows nothing at all. Only the kernel's own
# view can tell the difference, and disabling the output makes it re-acquire.
#
# Safe to call when the TV is already working: it does nothing.

set -euo pipefail

source ~/.config/hypr/scripts/tv.env

drm_state() {
    cat /sys/class/drm/card*-"$TV_MONITOR"/enabled 2>/dev/null | head -1
}

hyprland_sees_tv() {
    hyprctl monitors -j | jq -e --arg m "$TV_MONITOR" 'any(.[]; .name == $m)' >/dev/null
}

# nothing plugged in at all — the caller decides what to say about that
hyprland_sees_tv || exit 1

[ "$(drm_state)" = "enabled" ] && exit 0

# take the mode straight from monitors.conf so it is not written down twice;
# a plain `hyprctl reload` is not enough, the output has to be re-stated
rule=$(sed -n "s/^monitor *= *$TV_MONITOR, *//p" ~/.config/hypr/monitors.conf | head -1 | tr -d ' ')
if [ -z "$rule" ]; then
    echo "tv-wake: no $TV_MONITOR line in monitors.conf" >&2
    exit 1
fi

hyprctl keyword monitor "$TV_MONITOR,disable" >/dev/null
sleep 3
hyprctl keyword monitor "$TV_MONITOR,$rule" >/dev/null
sleep 4

[ "$(drm_state)" = "enabled" ]
