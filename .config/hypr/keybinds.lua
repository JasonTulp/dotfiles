local mainMod     = "SUPER"
local sws         = "~/.config/hypr/scripts/session-ws.sh"
local scripts     = "~/.config/hypr/scripts"
local terminal    = "ghostty"
local browser     = "MOZ_ENABLE_WAYLAND=1 zen-browser"
local filemanager = "dolphin"
local ide         = "idea" -- luacheck: ignore (kept for parity with the old config)

hl.bind("SUPER + T", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + B", hl.dsp.exec_cmd(browser))
hl.bind("SUPER + E", hl.dsp.exec_cmd(filemanager))
hl.bind("SUPER + C", hl.dsp.exec_cmd(terminal .. " -e /home/jason/.local/bin/claude"))
hl.bind("SUPER + W", hl.dsp.exec_cmd(terminal .. " -e zsh -ic hel"))
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("zsh -ic hel"))

hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("pkill -x dms; sleep 0.5 && /usr/bin/dms run --session"))

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind("Print", hl.dsp.exec_cmd("sleep 0.3 && grimblast --freeze copy area"))

-- Window Movement/ resizing with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Resize active window with keyboard
hl.bind(mainMod .. " + equal", hl.dsp.window.resize({ x = 40, y = 40, relative = true }),   { repeating = true })
hl.bind(mainMod .. " + minus", hl.dsp.window.resize({ x = -40, y = -40, relative = true }), { repeating = true })

hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))

-- TV through the wall -- game display only, never part of a session
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd(scripts .. "/game-mode.sh toggle"))
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd(scripts .. "/tv-send.sh"))
hl.bind(mainMod .. " + ALT + G", hl.dsp.exec_cmd(scripts .. "/tv-mirror.sh"))

-- Window focus with keys
hl.bind(mainMod .. " + up",   hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Cycle between sessions with wraparound (right = up, left = down)
hl.bind(mainMod .. " + right", hl.dsp.exec_cmd(scripts .. "/session-cycle.sh next"))
hl.bind(mainMod .. " + left",  hl.dsp.exec_cmd(scripts .. "/session-cycle.sh prev"))

-- Window movement with keys
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.swap({ direction = "down" }))

-- Used to swap the current split order (Swap windows around)
hl.bind(mainMod .. " + X", hl.dsp.layout("swapsplit"))

-- Move window to workspace 1-9 (current session)
for i = 1, 9 do
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.exec_cmd(sws .. " movetoworkspace " .. i))
end

-- Move window to workspace 10
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.exec_cmd(sws .. " movetoworkspace 10"))
for _, name in ipairs({ "S", "N", "A", "D", "M" }) do
    hl.bind(mainMod .. " + SHIFT + " .. name, hl.dsp.window.move({ workspace = "name:" .. name }))
end

-- Switch to workspace 1-9 (current session)
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.exec_cmd(sws .. " workspace " .. i))
end

-- Workspace 10 = 0 key
hl.bind(mainMod .. " + 0", hl.dsp.exec_cmd(sws .. " workspace 10"))
for _, name in ipairs({ "S", "N", "A", "D", "M" }) do
    hl.bind(mainMod .. " + " .. name, hl.dsp.focus({ workspace = "name:" .. name }))
end

-- Sessions -- swap the whole desk, every workspace preserved
for i = 1, 4 do
    hl.bind(mainMod .. " + CTRL + " .. i, hl.dsp.exec_cmd(scripts .. "/session-switch.sh " .. i))
end
for i = 1, 4 do
    hl.bind(mainMod .. " + F" .. i, hl.dsp.exec_cmd(scripts .. "/session-switch.sh " .. i))
end

-- Move active window to session and follow it
for i = 1, 4 do
    hl.bind(mainMod .. " + CTRL + SHIFT + " .. i, hl.dsp.exec_cmd(scripts .. "/session-move.sh " .. i))
end
for i = 1, 4 do
    hl.bind(mainMod .. " + SHIFT + F" .. i, hl.dsp.exec_cmd(scripts .. "/session-move.sh " .. i))
end

-- Sessions (numpad)
local KP_SESSION = { "KP_End", "KP_Down", "KP_Next", "KP_Left" }
for i, key in ipairs(KP_SESSION) do
    hl.bind(mainMod .. " + CTRL + " .. key, hl.dsp.exec_cmd(scripts .. "/session-switch.sh " .. i))
end
for i, key in ipairs(KP_SESSION) do
    hl.bind(mainMod .. " + CTRL + SHIFT + " .. key, hl.dsp.exec_cmd(scripts .. "/session-move.sh " .. i))
end

-- Switch to workspace 1-9 (numpad, current session)
local KP_WORKSPACE = {
    "KP_End", "KP_Down", "KP_Next", "KP_Left", "KP_Begin",
    "KP_Right", "KP_Home", "KP_Up", "KP_Prior",
}
for i, key in ipairs(KP_WORKSPACE) do
    hl.bind(mainMod .. " + " .. key, hl.dsp.exec_cmd(sws .. " workspace " .. i))
end

-- Workspace 10 = numpad 0
hl.bind(mainMod .. " + KP_Insert", hl.dsp.exec_cmd(sws .. " workspace 10"))

-- Move window to workspace 1-9 (numpad, current session)
for i, key in ipairs(KP_WORKSPACE) do
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.exec_cmd(sws .. " movetoworkspace " .. i))
end

-- Move window to workspace 10 (numpad)
hl.bind(mainMod .. " + SHIFT + KP_Insert", hl.dsp.exec_cmd(sws .. " movetoworkspace 10"))

-- Volume controls
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))

-- Media controls (works with media keys or mouse buttons configured to send these)
hl.bind("XF86AudioPlay",      hl.dsp.exec_cmd("playerctl -p spotify play-pause"))
hl.bind("XF86AudioPause",     hl.dsp.exec_cmd("playerctl -p spotify pause"))
-- XF86AudioPlayPause is not a keysym on this system (it is absent from
-- xkbcommon-keysyms.h), so the old .conf bind for it registered with keycode 0
-- and could never fire. The Lua parser rejects it outright, so it is dropped;
-- XF86AudioPlay above already sends play-pause.
hl.bind("XF86AudioNext",      hl.dsp.exec_cmd("playerctl -p spotify next"))
hl.bind("XF86AudioPrev",      hl.dsp.exec_cmd("playerctl -p spotify previous"))
