#!/usr/bin/env bash
# Send the focused window to the TV, or send it back where it came from.
# Same key both ways: press it on a desk window to throw it at the TV, press it
# again on the TV to bring it home.

set -euo pipefail

source ~/.config/hypr/scripts/tv.env

state_dir="${XDG_RUNTIME_DIR:-/tmp}/hypr-gamemode"
mkdir -p "$state_dir"
origins="$state_dir/origins"
touch "$origins"

# with the TV off there is no HDMI-A-1, and name:TV would land on the desk
if ! hyprctl monitors -j | jq -e --arg m "$TV_MONITOR" 'any(.[]; .name == $m)' >/dev/null; then
    notify-send -a "TV" "TV not connected" "Turn the TV on first." 2>/dev/null || true
    exit 1
fi

window=$(hyprctl activewindow -j)
address=$(jq -r '.address // empty' <<<"$window")
workspace=$(jq -r '.workspace.name // empty' <<<"$window")

if [ -z "$address" ]; then
    exit 0
fi

# a numeric workspace is dispatched as-is, a named one needs the name: prefix
as_token() {
    case "$1" in
        ''|*[!0-9]*) echo "name:$1" ;;
        *) echo "$1" ;;
    esac
}

if [ "$(as_token "$workspace")" = "$TV_WORKSPACE" ]; then
    origin=$(awk -v a="$address" '$1 == a { print $2 }' "$origins" | tail -n 1)
    if [ -z "$origin" ]; then
        # no record of where it came from: fall back to the centre monitor
        origin=$(hyprctl monitors -j \
            | jq -r --arg m "$TV_MONITOR" \
                'first(.[] | select(.name != $m) | .activeWorkspace
                 | if .id > 0 then (.id | tostring) else "name:" + .name end)')
    fi
    grep -v "^$address " "$origins" > "$origins.tmp" || true
    mv "$origins.tmp" "$origins"
    hyprctl dispatch movetoworkspace "$origin"
else
    echo "$address $(as_token "$workspace")" >> "$origins"
    hyprctl dispatch movetoworkspace "$TV_WORKSPACE"
fi
