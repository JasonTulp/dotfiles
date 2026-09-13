#!/usr/bin/env python3
"""Keep the rotated right monitor stacking windows top/bottom only.

Dwindle picks a split axis from the container's aspect ratio (and the global
dwindle:split_width_multiplier) — there is no per-monitor setting, so on the
portrait monitor the first split is top/bottom but every container after that is
wider than it is tall and splits side by side.

This listens on the Hyprland event socket and enforces one invariant: a tiled
window focused on the target monitor spans the full width. Whenever a window
opens there, is moved there, is unfloated there, or is simply focused there and
sits beside its neighbour instead of below it, `layoutmsg togglesplit` stacks it.
Needs dwindle:preserve_split = true (layout.conf) so the axis is not recomputed
the next time the container is resized.

Only ever touches the focused window, so it can't yank focus around.
Run with --dry-run to log decisions without dispatching anything.
"""

import json
import os
import socket
import subprocess
import sys
import time

# substring of the monitor description (see `hyprctl monitors`)
STACK_MONITOR = "AOC Q32V3WG5"

# a window narrower than this fraction of the monitor is beside something
FULL_WIDTH_RATIO = 0.85

# how many nested side-by-side splits to unpick for one window
MAX_TOGGLES = 4

# pause before re-reading a width, so a window still being mapped isn't misread,
# and between toggles. hyprctl round-trips are ~3ms, so these set the visible lag
SETTLE_DELAY = 0.03
TOGGLE_DELAY = 0.03

# anything that can insert a window into this monitor's layout, plus plain focus
# changes so windows that opened unfocused get fixed as soon as they are used
EVENTS = ("openwindow", "movewindowv2", "activewindowv2", "changefloatingmode")

DRY_RUN = "--dry-run" in sys.argv


def log(msg):
    print(f"stack-right-monitor: {msg}", file=sys.stderr, flush=True)


def hyprctl_json(*args):
    out = subprocess.run(
        ["hyprctl", "-j", *args], capture_output=True, text=True, check=True
    ).stdout
    return json.loads(out)


def logical_width(monitor):
    width, height = monitor["width"], monitor["height"]
    if monitor["transform"] in (1, 3, 5, 7):  # rotated 90 / 270
        width, height = height, width
    return width / monitor["scale"]


def stack_monitor():
    for monitor in hyprctl_json("monitors"):
        if STACK_MONITOR in monitor["description"]:
            return monitor
    return None


def candidate():
    """The focused window if it is tiled on the stack monitor, else None.

    Returns (window, full width of the monitor). Note named workspaces (N, M, …)
    have negative ids in Hyprland — only `special:` ones are the scaled-down
    overlays we want to leave alone.
    """
    monitor = stack_monitor()
    if monitor is None:
        return None, 0.0

    window = hyprctl_json("activewindow")
    if not window or window.get("monitor") != monitor["id"]:
        return None, 0.0
    if window["floating"] or window["fullscreen"]:
        return None, 0.0
    if window["workspace"]["name"].startswith("special:"):
        return None, 0.0
    return window, logical_width(monitor)


def full_width(window, monitor_width):
    return window["size"][0] >= monitor_width * FULL_WIDTH_RATIO


def stack_focused():
    window, monitor_width = candidate()
    if window is None or full_width(window, monitor_width):
        return

    # re-read: a window still animating in could report a transient width
    time.sleep(SETTLE_DELAY)
    window, monitor_width = candidate()
    if window is None or full_width(window, monitor_width):
        return

    # each togglesplit stacks the window with its sibling, which widens it to its
    # parent's width — repeat to unpick a column that is nested more than once
    address = window["address"]
    for _ in range(MAX_TOGGLES):
        width = window["size"][0]
        log(f"{window['class']} is {width:.0f}px of {monitor_width:.0f}px — stacking")
        if DRY_RUN:
            return
        subprocess.run(["hyprctl", "dispatch", "layoutmsg", "togglesplit"],
                       capture_output=True, check=False)
        time.sleep(TOGGLE_DELAY)

        window, monitor_width = candidate()
        if window is None or window["address"] != address:
            return
        if full_width(window, monitor_width):
            return
        if abs(window["size"][0] - width) < 1:
            log(f"togglesplit did not widen {window['class']} — giving up")
            return


def event_socket():
    signature = os.environ["HYPRLAND_INSTANCE_SIGNATURE"]
    runtime = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.connect(f"{runtime}/hypr/{signature}/.socket2.sock")
    return sock


def main():
    sock = event_socket()
    if DRY_RUN:
        log("dry run — will log but not dispatch")

    with sock.makefile("rb") as stream:
        for line in stream:
            name = line.decode(errors="replace").strip().partition(">>")[0]
            if name not in EVENTS:
                continue
            try:
                stack_focused()
            except Exception as err:  # keep the daemon alive
                log(f"{name}: {err}")


if __name__ == "__main__":
    main()
