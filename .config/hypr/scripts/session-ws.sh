#!/usr/bin/env bash
# Dispatch workspace/movetoworkspace inside the current session's namespace.
# Session s, workspace k -> real workspace (s-1)*100 + k

set -euo pipefail

action=${1:?usage: session-ws.sh <workspace|movetoworkspace> <1-10>}
k=${2:?missing workspace number}

state_dir="${XDG_RUNTIME_DIR:-/tmp}/hypr-sessions"
session=$(cat "$state_dir/current" 2>/dev/null || echo 1)

hyprctl dispatch "$action" $(( (session - 1) * 100 + k ))
