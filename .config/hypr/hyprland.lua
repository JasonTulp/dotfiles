-- DMS regenerates dms/outputs.lua with connector names whenever its display
-- settings are touched. Require it first so the hand-written monitors.lua
-- always wins. pcall because require() on a missing module would otherwise
-- abort this whole file, and the fragment only appears once DMS writes it
-- (run `dms setup` after migrating; it still has the old outputs.conf here).
pcall(require, "dms.outputs")
require("monitors")
require("animations")
require("keybinds")
require("layout")

hl.config({
    general = {
        col = {
            active_border   = "rgb(e08b0b)",
            inactive_border = "rgb(212121)",
        },
    },

    input = {
        float_switch_override_focus = 0,
        follow_mouse                = 2,
        mouse_refocus               = true,
        numlock_by_default          = true,
    },

    -- Fixes the weird issue where the cursor wouldn't go all the way to the right side
    cursor = {
        no_hardware_cursors = true,
    },

    xwayland = {
        force_zero_scaling = true,
    },

    decoration = {
        blur = {
            enabled = true,
            size    = 8,
            passes  = 2,
        },
    },

    -- Allow Hyprland to open programs in the initial workspace, regardless of current mouse position
    misc = {
        initial_workspace_tracking = 1,
    },
})

hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
hl.env("PATH", os.getenv("PATH") .. ":/usr/local/go/bin")

-- Used for unity to support wayland
hl.env("SDL_VIDEODRIVER", "wayland")

hl.layer_rule({
    name         = "rofi-blur",
    match        = { namespace = "rofi" },
    blur         = true,
    ignore_alpha = 0.3,
})

hl.on("hyprland.start", function()
    -- For Dank Materials Shell https://danklinux.com/docs/dankmaterialshell
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user start graphical-session.target")
    hl.exec_cmd("/usr/bin/dms run --session")

    -- Right monitor is portrait: only ever stack windows top/bottom there
    hl.exec_cmd("~/.config/hypr/scripts/stack-right-monitor.py")

    -- Spotify on workspace S
    hl.exec_cmd("spotify")
end)

hl.window_rule({
    name      = "windowrule-1",
    match     = { class = "^(Spotify)$" },
    workspace = "name:S",
})

-- Game mode runs Steam inside gamescope, and that nest is a single Wayland
-- window whose app id is always "gamescope". Everything Steam opens lives inside
-- it, so this one rule is enough to keep games off the desk monitors.
hl.window_rule({
    name      = "tv-gamescope",
    match     = { class = "^(gamescope)$" },
    workspace = "name:TV",
})

-- Kept for a Big Picture opened by hand, outside game mode
hl.window_rule({
    name      = "tv-bigpicture",
    match     = { title = "^(Steam Big Picture Mode)$" },
    workspace = "name:TV",
})
