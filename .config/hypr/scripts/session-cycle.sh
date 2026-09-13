#!/usr/bin/env bash
# Cycle to the next/previous session with wraparound (sessions 1-4).
#   session-cycle.sh next   -> 1->2->3->4->1
#   session-cycle.sh prev   -> 1->4->3->2->1

set -euo pipefail

dir=${1:?usage: session-cycle.sh <next|prev>}

count=4
state_dir="${XDG_RUNTIME_DIR:-/tmp}/hypr-sessions"
current=$(cat "$state_dir/current" 2>/dev/null || echo 1)

case "$dir" in
    next) target=$(( current % count + 1 )) ;;
    prev) target=$(( (current - 2 + count) % count + 1 )) ;;
    *) echo "usage: session-cycle.sh <next|prev>" >&2; exit 1 ;;
esac

exec ~/.config/hypr/scripts/session-switch.sh "$target"
