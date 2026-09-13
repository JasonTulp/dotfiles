#!/usr/bin/env bash
# Move the active window to session $1 and follow it.
# Lands on the same workspace number in the target session (same monitor).

set -euo pipefail

target=${1:?usage: session-move.sh <1-4>}

ws=$(hyprctl activewindow -j | jq -r '.workspace.id // empty')

# no active window, or window on a shared named workspace (S)
if [ -z "$ws" ] || [ "$ws" -le 0 ]; then
    exit 0
fi

k=$(( ws % 100 ))
from_session=$(( ws / 100 + 1 ))

if [ "$from_session" = "$target" ]; then
    exit 0
fi

target_ws=$(( (target - 1) * 100 + k ))

hyprctl dispatch movetoworkspacesilent "$target_ws"
~/.config/hypr/scripts/session-switch.sh "$target"
hyprctl dispatch workspace "$target_ws"
