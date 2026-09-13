#!/usr/bin/env bash
# Game mode: Steam Big Picture on the TV inside gamescope, audio on the TV,
# cursor back on the desk. Whether game mode is on is read from the running
# gamescope and the saved audio state, never from a marker file, so killing
# gamescope by hand cannot leave the toggle out of step.
#
#   game-mode.sh          toggle
#   game-mode.sh on|off
#   game-mode.sh focus    move the keyboard to the TV, or take it back
#   game-mode.sh sinks    show which HDMI audio profile feeds which monitor
#
# Why gamescope rather than plain Steam: Steam picks the controller profile
# from whichever window it believes is in the foreground, and on Wayland it can
# only see that through XWayland. Any moment the keyboard sits on a desk window
# it falls back to its Desktop profile and the controller turns into a mouse.
# Inside gamescope, Steam and every game it starts are one nested compositor
# behind a single Hyprland window, so Steam always knows what is focused, games
# cannot open on the wrong monitor, and the overlay composites at the TV's rate.

set -euo pipefail

source ~/.config/hypr/scripts/tv.env

state_dir="${XDG_RUNTIME_DIR:-/tmp}/hypr-gamemode"
mkdir -p "$state_dir"

pidfile="$state_dir/gamescope.pid"
logfile="$state_dir/gamescope.log"

# Steam from cold inside a fresh nested XWayland is slow, and nothing shows in
# Hyprland until Big Picture presents its first frame
GAMESCOPE_TIMEOUT=90

# how long to give a desktop Steam to close itself before giving up on it
STEAM_SHUTDOWN_TIMEOUT=30

notify() {
    command -v notify-send >/dev/null || return 0
    notify-send -a "Game mode" "$1" "${2:-}" || true
}

tv_connected() {
    hyprctl monitors -j | jq -e --arg m "$TV_MONITOR" 'any(.[]; .name == $m)' >/dev/null
}

# ---------------------------------------------------------------- gamescope --

gamescope_pid() {
    local pid
    [ -f "$pidfile" ] || return 1
    pid=$(cat "$pidfile")
    [ -n "$pid" ] || return 1
    kill -0 "$pid" 2>/dev/null || return 1
    echo "$pid"
}

# gamescope's Hyprland window is a native Wayland surface with this app id; its
# title mirrors whatever is on top inside the nest, so it cannot be matched on
gamescope_address() {
    hyprctl clients -j \
        | jq -r 'first(.[] | select(.class == "gamescope") | .address) // empty'
}

wait_for_gamescope() {
    local address i
    for i in $(seq "$GAMESCOPE_TIMEOUT"); do
        address=$(gamescope_address)
        if [ -n "$address" ]; then
            echo "$address"
            return 0
        fi
        gamescope_pid >/dev/null || return 1
        sleep 1
    done
    return 1
}

# gamescope must own the Steam process tree. A Steam that is already up would
# just be told to open Big Picture and would draw it on the desktop instead,
# outside the nest, which is the whole problem this is meant to fix.
steam_running() {
    pgrep -x steam >/dev/null
}

# the reaper wrapper is also used for Steam's own script evaluator, which comes
# and goes on its own and is not a game
game_running() {
    pgrep -af "reaper SteamLaunch" 2>/dev/null | grep -qv iscriptevaluator
}

shutdown_steam() {
    steam -shutdown >/dev/null 2>&1 || true
    local i
    for i in $(seq "$STEAM_SHUTDOWN_TIMEOUT"); do
        steam_running || return 0
        sleep 1
    done
    return 1
}

launch_gamescope() {
    # the pid is written by the subshell that then execs gamescope, so the
    # pidfile holds gamescope itself rather than a wrapper that has exited.
    #
    # WAYLAND_DISPLAY is dropped for the nested Steam: without --expose-wayland
    # gamescope does not hand children its own display, so they would otherwise
    # inherit Hyprland's and a Wayland-native game could open straight onto a
    # desk monitor. With it unset everything falls back to gamescope's XWayland.
    setsid bash -c '
        echo $$ > "$1"
        exec env SDL_VIDEODRIVER="$2" STEAM_MULTIPLE_XWAYLANDS=1 \
            gamescope \
                --backend wayland \
                -W "$3" -H "$4" -r "$5" \
                --fullscreen \
                --steam \
                --xwayland-count 2 \
                -- env -u WAYLAND_DISPLAY steam -bigpicture
    ' _ "$pidfile" "$TV_STEAM_SDL_VIDEODRIVER" \
        "$TV_GAMESCOPE_WIDTH" "$TV_GAMESCOPE_HEIGHT" "$TV_GAMESCOPE_REFRESH" \
        >"$logfile" 2>&1 &
    disown
}

# gamescope exits with a segfault on teardown often enough that its status is
# not worth reading; what matters is that the process is gone
stop_gamescope() {
    local pid i
    pid=$(gamescope_pid) || return 0

    # ask the nested Steam to close, which ends gamescope's primary child
    steam -shutdown >/dev/null 2>&1 || true
    for i in $(seq "$STEAM_SHUTDOWN_TIMEOUT"); do
        kill -0 "$pid" 2>/dev/null || { rm -f "$pidfile"; return 0; }
        sleep 1
    done

    kill -TERM "$pid" 2>/dev/null || true
    sleep 2
    kill -KILL "$pid" 2>/dev/null || true
    rm -f "$pidfile"
}

# game mode counts as on while gamescope is up OR while the desk audio is still
# parked, so a half-finished state can always be undone with one press
game_mode_active() {
    gamescope_pid >/dev/null || [ -f "$state_dir/prev-sink" ]
}

# -------------------------------------------------------------------- audio --

# pactl's plain output has to be read whole: piping it into an early-exiting
# grep or head raises SIGPIPE, which pipefail turns into a fatal error
card_profile() {
    pactl -f json list cards \
        | jq -r --arg c "$TV_AUDIO_CARD" '.[] | select(.name == $c) | .active_profile'
}

hdmi_sink_monitor() {
    pactl -f json list sinks \
        | jq -r 'first(.[] | select(.name | test("hdmi")) | .properties["alsa.name"]) // "-"'
}

# the GPU exposes one HDMI sink at a time, so the card profile has to move too
audio_to_tv() {
    if [ ! -f "$state_dir/prev-sink" ]; then
        card_profile > "$state_dir/prev-profile"
        pactl get-default-sink > "$state_dir/prev-sink"
    fi
    pactl set-card-profile "$TV_AUDIO_CARD" "$TV_AUDIO_PROFILE"
    sleep 1
    pactl set-default-sink "$TV_SINK"
}

audio_to_desk() {
    if [ -f "$state_dir/prev-sink" ]; then
        pactl set-card-profile "$TV_AUDIO_CARD" "$(cat "$state_dir/prev-profile")" || true
        sleep 1
        pactl set-default-sink "$(cat "$state_dir/prev-sink")" || true
    fi
    rm -f "$state_dir/prev-sink" "$state_dir/prev-profile"
}

# -------------------------------------------------------- cursor and focus --

save_desk_position() {
    hyprctl cursorpos > "$state_dir/desk-cursor"
    hyprctl activewindow -j | jq -r '.address // empty' > "$state_dir/desk-window"
}

# Only the pointer is put back, never the keyboard. `dispatch focusmonitor`
# would look like the obvious way to do this, but it moves keyboard focus as
# well, and that is exactly what drops Steam into its Desktop controller
# profile. With input:follow_mouse = 2 the cursor is already detached from the
# keyboard, so moving it alone leaves the TV holding focus.
restore_desk_cursor() {
    [ -s "$state_dir/desk-cursor" ] || return 0
    local x y
    x=$(cut -d',' -f1 < "$state_dir/desk-cursor" | tr -d ' ')
    y=$(cut -d',' -f2 < "$state_dir/desk-cursor" | tr -d ' ')
    hyprctl dispatch movecursor "$x" "$y" >/dev/null
}

restore_desk_focus() {
    local window
    window=$(cat "$state_dir/desk-window" 2>/dev/null || true)
    if [ -n "$window" ] && hyprctl clients -j \
        | jq -e --arg a "$window" 'any(.[]; .address == $a)' >/dev/null; then
        hyprctl dispatch focuswindow "address:$window" >/dev/null
    else
        # the window is gone, so fall back to whatever the mirror monitor holds
        hyprctl dispatch focusmonitor "$MIRROR_MONITOR" >/dev/null
    fi
    restore_desk_cursor
}

focus_tv() {
    local address
    address=$(gamescope_address)
    if [ -n "$address" ]; then
        hyprctl dispatch focuswindow "address:$address" >/dev/null
    else
        tv_connected || { notify "TV not connected"; exit 1; }
        hyprctl --batch \
            "dispatch focusmonitor $TV_MONITOR; dispatch workspace $TV_WORKSPACE" >/dev/null
    fi
}

focused_on_tv() {
    local active
    active=$(hyprctl activewindow -j | jq -r '.address // empty')
    [ -n "$active" ] && [ "$active" = "$(gamescope_address)" ]
}

# ------------------------------------------------------------------ toggles --

game_mode_on() {
    # Hyprland can list the TV while the kernel never lit it, so make sure
    # it is really on before gamescope is sent somewhere invisible
    if ! ~/.config/hypr/scripts/tv-wake.sh; then
        notify "TV not ready" "No $TV_MONITOR output, or it would not light."
        exit 1
    fi

    if game_running; then
        notify "A game is already running" \
            "Quit it first — game mode has to restart Steam inside gamescope."
        exit 1
    fi

    if gamescope_pid >/dev/null; then
        notify "Game mode already on" "Bringing focus back to the TV."
        focus_tv
        return 0
    fi

    if steam_running; then
        notify "Closing desktop Steam" "It has to be restarted inside gamescope."
        if ! shutdown_steam; then
            notify "Steam would not close" "Quit it by hand and press the key again."
            exit 1
        fi
    fi

    audio_to_tv
    save_desk_position

    # launch from the TV workspace so misc:initial_workspace_tracking puts the
    # gamescope window there without waiting on the window rule
    hyprctl --batch \
        "dispatch focusmonitor $TV_MONITOR; dispatch workspace $TV_WORKSPACE" >/dev/null

    launch_gamescope

    local address
    if ! address=$(wait_for_gamescope); then
        notify "gamescope did not come up" "See $logfile"
        restore_desk_cursor
        return 1
    fi

    # place the window ourselves rather than trusting the window rule, and
    # leave the keyboard on it so Steam keeps its Big Picture controller profile
    hyprctl --batch \
        "dispatch movetoworkspacesilent $TV_WORKSPACE,address:$address; dispatch focuswindow address:$address" >/dev/null

    # gamescope asks for fullscreen itself, so only step in if it did not take
    if [ "$(hyprctl clients -j | jq -r --arg a "$address" \
            'first(.[] | select(.address == $a) | .fullscreen)')" = "0" ]; then
        hyprctl dispatch fullscreen 0 >/dev/null
    fi

    restore_desk_cursor
    notify "Game mode on" "Big Picture and sound on the TV"
}

game_mode_off() {
    stop_gamescope
    audio_to_desk

    restore_desk_focus

    notify "Game mode off" "Audio and focus back on the desk"
}

# --------------------------------------------------------------------- main --

case "${1:-toggle}" in
    on)  game_mode_on ;;
    off) game_mode_off ;;
    toggle)
        if game_mode_active; then game_mode_off; else game_mode_on; fi
        ;;
    focus)
        if focused_on_tv; then
            restore_desk_focus
        else
            save_desk_position
            focus_tv
        fi
        ;;
    sinks)
        original=$(card_profile)
        echo "HDMI audio profile -> monitor:"
        for profile in output:hdmi-stereo output:hdmi-stereo-extra1 \
                       output:hdmi-stereo-extra2 output:hdmi-stereo-extra3; do
            pactl set-card-profile "$TV_AUDIO_CARD" "$profile" 2>/dev/null || continue
            sleep 1
            printf "  %-32s %s\n" "$profile" "$(hdmi_sink_monitor)"
        done
        pactl set-card-profile "$TV_AUDIO_CARD" "$original"
        echo "tv.env uses: $TV_AUDIO_PROFILE -> $TV_SINK"
        ;;
    *)
        echo "usage: game-mode.sh [toggle|on|off|focus|sinks]" >&2
        exit 1
        ;;
esac
