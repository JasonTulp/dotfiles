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

# `monitors all`, because monitors.lua leaves the TV disabled: a disabled output
# is off the plain list, while a connector with nothing in it drops off both.
hyprland_sees_tv() {
    hyprctl monitors all -j | jq -e --arg m "$TV_MONITOR" 'any(.[]; .name == $m)' >/dev/null
}

# nothing plugged in at all — the caller decides what to say about that
hyprland_sees_tv || exit 1

[ "$(drm_state)" = "enabled" ] && exit 0

# take the mode straight from monitors.lua so it is not written down twice:
# that file leaves the TV's spec in the global TV_MODE, which the config's Lua
# state still holds, so it is read back live rather than re-parsed off disk.
# A plain `hyprctl reload` is not enough, the output has to be re-stated.
if ! hyprctl repl 'return type(TV_MODE)' 2>/dev/null | grep -qx table; then
    echo "tv-wake: TV_MODE not set by monitors.lua" >&2
    exit 1
fi

# `hyprctl keyword` does not exist under the Lua config; hl.monitor via eval is
# the replacement.
hyprctl eval 'hl.monitor({ output = TV_MODE.output, disabled = true })' >/dev/null
sleep 3
hyprctl eval 'hl.monitor(TV_MODE)' >/dev/null
sleep 4

[ "$(drm_state)" = "enabled" ]
