#!/usr/bin/env bash
# Switch to session $1: save what each monitor is showing in the current
# session, then restore the target session (or its defaults if new).

set -euo pipefail

target=${1:?usage: session-switch.sh <1-4>}

# the TV is not part of any session — never save or restore what it shows
source ~/.config/hypr/scripts/tv.env

state_dir="${XDG_RUNTIME_DIR:-/tmp}/hypr-sessions"
mkdir -p "$state_dir"
current=$(cat "$state_dir/current" 2>/dev/null || echo 1)

if [ "$target" = "$current" ]; then
    exit 0
fi

# remember each monitor's visible workspace (named workspaces as name:X)
hyprctl monitors -j \
    | jq -r --arg tv "$TV_MONITOR" '.[] | select(.name != $tv) | .activeWorkspace
             | if .id > 0 then (.id | tostring) else "name:" + .name end' \
    > "$state_dir/session-$current"

focused=$(hyprctl monitors -j \
    | jq -r --arg tv "$TV_MONITOR" 'first(.[] | select(.focused and .name != $tv) | .name)
             // first(.[] | select(.name != $tv) | .name)')
cursor_x=$(hyprctl cursorpos | cut -d',' -f1 | tr -d ' ')
cursor_y=$(hyprctl cursorpos | cut -d',' -f2 | tr -d ' ')

if [ -f "$state_dir/session-$target" ]; then
    mapfile -t workspaces < "$state_dir/session-$target"
else
    # fresh session: the equivalents of workspaces 7 / 1 / 9
    base=$(( (target - 1) * 100 ))
    workspaces=( "$((base + 7))" "$((base + 1))" "$((base + 9))" )
fi

# cross-fade sessions (non-directional) to distinguish them from intra-session
# switches; restore the normal horizontal slide (mirrors animations.lua) once
# the transition has played out. duration is 4ds (400ms), so reset after 0.6s.
anim() {
    hyprctl eval "hl.animation({ leaf = \"workspaces\", enabled = true, speed = 4, bezier = \"smooth\", style = \"$1\" })" >/dev/null
}
anim fade
( sleep 0.6; anim slide ) &
disown

# workspace rules pin each id to its monitor, so order doesn't matter;
# refocus the original monitor and put the cursor back where it was
# (focusmonitor warps the cursor when triggered from a bar click)
# one eval rather than --batch: --batch splits on ";", which is also Lua's
# statement separator, so the whole sequence goes over as a single Lua chunk
lua=""
for ws in "${workspaces[@]}"; do
    lua+="hl.dispatch(hl.dsp.focus({ workspace = \"$ws\" })) "
done
lua+="hl.dispatch(hl.dsp.focus({ monitor = \"$focused\" })) "
lua+="hl.dispatch(hl.dsp.cursor.move({ x = $cursor_x, y = $cursor_y }))"

hyprctl eval "$lua" >/dev/null
echo "$target" > "$state_dir/current"
