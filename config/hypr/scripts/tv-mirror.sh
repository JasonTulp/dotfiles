#!/usr/bin/env bash
# Show the TV on the centre monitor as well, so it can be watched and driven
# from the desk. The centre monitor stops showing its own workspaces until this
# is toggled off, which is what makes both screens show the same thing.
#
#   tv-mirror.sh   toggle (default)
#   tv-mirror.sh   on|off

set -euo pipefail

source ~/.config/hypr/scripts/tv.env

state_dir="${XDG_RUNTIME_DIR:-/tmp}/hypr-gamemode"
mkdir -p "$state_dir"

notify() {
    command -v notify-send >/dev/null || return 0
    notify-send -a "TV mirror" "$1" "${2:-}" || true
}

monitor_present() {
    hyprctl monitors -j | jq -e --arg m "$1" 'any(.[]; .name == $m)' >/dev/null
}

# a mirroring output drops out of the monitor list entirely
mirroring() {
    ! monitor_present "$MIRROR_MONITOR"
}

mirror_on() {
    if ! ~/.config/hypr/scripts/tv-wake.sh; then
        notify "TV not ready" "No $TV_MONITOR output, or it would not light."
        exit 1
    fi

    # Hyprland moves a mirroring monitor's workspaces to other outputs, so
    # remember which ones to bring home again
    hyprctl workspaces -j \
        | jq -r --arg m "$MIRROR_MONITOR" '.[] | select(.monitor == $m) | .id' \
        > "$state_dir/mirror-workspaces"
    hyprctl monitors -j \
        | jq -r --arg m "$MIRROR_MONITOR" '.[] | select(.name == $m) | .activeWorkspace.id' \
        > "$state_dir/mirror-active"

    local spec
    spec=$(hyprctl monitors -j | jq -r --arg m "$MIRROR_MONITOR" \
        '.[] | select(.name == $m)
         | "mode = \"\(.width)x\(.height)@\(.refreshRate | round)\", position = \"\(.x)x\(.y)\", scale = \(.scale)"')

    # `hyprctl keyword` does not exist under the Lua config; hl.monitor via eval
    # is the replacement.
    hyprctl eval "hl.monitor({ output = \"$MIRROR_MONITOR\", $spec, mirror = \"$TV_MONITOR\" })" >/dev/null
    sleep 1

    # drive the TV from here: input follows the cursor, so it has to go over
    hyprctl eval "hl.dispatch(hl.dsp.focus({ monitor = \"$TV_MONITOR\" })) hl.dispatch(hl.dsp.focus({ workspace = \"$TV_WORKSPACE\" }))" >/dev/null
    notify "TV mirrored" "$MIRROR_MONITOR is showing the TV"
}

mirror_off() {
    # monitors.lua is the one place the real geometry lives, so re-read it
    # rather than keeping a second copy of the monitor line in this script
    hyprctl reload >/dev/null
    sleep 2

    if [ -f "$state_dir/mirror-workspaces" ]; then
        local workspace
        while read -r workspace; do
            [ -n "$workspace" ] || continue
            hyprctl dispatch "hl.dsp.workspace.move({ workspace = \"$workspace\", monitor = \"$MIRROR_MONITOR\" })" >/dev/null
        done < "$state_dir/mirror-workspaces"
    fi

    if [ -s "$state_dir/mirror-active" ]; then
        hyprctl eval "hl.dispatch(hl.dsp.focus({ monitor = \"$MIRROR_MONITOR\" })) hl.dispatch(hl.dsp.focus({ workspace = \"$(cat "$state_dir/mirror-active")\" }))" >/dev/null
    fi

    rm -f "$state_dir/mirror-workspaces" "$state_dir/mirror-active"
    notify "TV mirror off" "$MIRROR_MONITOR is back to its own workspaces"
}

case "${1:-toggle}" in
    on)  mirror_on ;;
    off) mirror_off ;;
    toggle)
        if mirroring; then mirror_off; else mirror_on; fi
        ;;
    *)
        echo "usage: tv-mirror.sh [toggle|on|off]" >&2
        exit 1
        ;;
esac
