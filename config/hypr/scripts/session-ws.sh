#!/usr/bin/env bash
# Dispatch workspace/movetoworkspace inside the current session's namespace.
# Session s, workspace k -> real workspace (s-1)*100 + k

set -euo pipefail

action=${1:?usage: session-ws.sh <workspace|movetoworkspace> <1-10>}
k=${2:?missing workspace number}

state_dir="${XDG_RUNTIME_DIR:-/tmp}/hypr-sessions"
session=$(cat "$state_dir/current" 2>/dev/null || echo 1)

ws=$(( (session - 1) * 100 + k ))

# `hyprctl dispatch` takes a Lua expression now that the config is Lua; the old
# `dispatch workspace 5` form is rejected by the parser.
case "$action" in
    workspace)
        hyprctl dispatch "hl.dsp.focus({ workspace = \"$ws\" })"
        ;;
    movetoworkspace)
        hyprctl dispatch "hl.dsp.window.move({ workspace = \"$ws\" })"
        ;;
    *)
        echo "session-ws.sh: unknown action '$action'" >&2
        exit 1
        ;;
esac
