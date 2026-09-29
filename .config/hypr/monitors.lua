-- Desk monitors are matched by description, so a cable moving between
-- connectors changes nothing. The 4Ks sit at y=608 to bottom-align with the
-- portrait monitor (2048 logical tall - 1440 = 608).

local CENTER = "desc:Samsung Electric Company Odyssey G70B"
local LEFT   = "desc:Samsung Electric Company U28E590"
local RIGHT  = "desc:AOC Q32V3WG5"
local TV     = "HDMI-A-1"

-- Left - 4K 60Hz (U28E590)
hl.monitor({ output = LEFT, mode = "3840x2160@60", position = "0x608", scale = 1.5 })

-- Center - 4K (Odyssey G70B). Pinned to 120Hz: the GPU cannot drive a 4th
-- head alongside this panel at 144Hz, and whichever output asks first wins,
-- which otherwise leaves the TV listed by Hyprland but never lit.
hl.monitor({ output = CENTER, mode = "3840x2160@120", position = "2560x608", scale = 1.5 })

-- Right - 2K 60Hz, rotated 90 degrees left (Q32V3WG5, on DP-3)
hl.monitor({ output = RIGHT, mode = "2560x1440@60", position = "5120x0", scale = 1.25, transform = 1 })

-- TV through the wall on HDMI-1. Parked far past the right edge of the desk so
-- no monitor edge touches it and the cursor can never cross to it -- only
-- scripts/game-mode.sh and scripts/tv-send.sh put anything on it.
--
-- 1080p60, not 4K: the EDID that reaches this end of the wall run caps TMDS at
-- 300 MHz, which is HDMI 1.4 bandwidth, so the panel offers 4K only at 30 Hz.
-- Asking for 3840x2160@60 fell back to 30 Hz without a word, which is what made
-- Big Picture, the Steam overlay and games on the TV all feel half-speed.
-- If the cable or the TV's HDMI mode changes, check `hyprctl monitors all` for a
-- 3840x2160@60 entry before putting 4K back here -- and keep tv.env in step.
--
-- scripts/tv-wake.sh re-states this mode after the TV is switched back on, and
-- reads it straight out of this table so it is not written down twice.
TV_MODE = { output = TV, mode = "1920x1080@60", position = "20000x0", scale = 1 }
hl.monitor(TV_MODE)

-- Workspace assignments
-- Center monitor (Odyssey G70B): 1-6
-- Left monitor (U28E590): 7-8, S/A/D (named, session-global)
-- Right monitor (Q32V3WG5): 9-0, N (notes, session-global), M (session-global)
for i = 1, 6 do
    hl.workspace_rule({ workspace = tostring(i), monitor = CENTER, default = (i == 1) })
end
for i = 7, 8 do
    hl.workspace_rule({ workspace = tostring(i), monitor = LEFT, default = (i == 7) })
end
for _, name in ipairs({ "S", "A", "D" }) do
    hl.workspace_rule({ workspace = "name:" .. name, monitor = LEFT })
end
for i = 9, 10 do
    hl.workspace_rule({ workspace = tostring(i), monitor = RIGHT, default = (i == 9) })
end
for _, name in ipairs({ "N", "M" }) do
    hl.workspace_rule({ workspace = "name:" .. name, monitor = RIGHT })
end

-- TV (game display): one workspace, no gaps or borders, never a default target
hl.workspace_rule({
    workspace   = "name:TV",
    monitor     = TV,
    default     = true,
    gaps_in     = 0,
    gaps_out    = 0,
    no_border   = true,
    no_rounding = true,
})

-- Sessions: workspace set duplicated at +100 per session (scripts/session-*.sh)
-- Session 2: middle 101-106, left 107-108, right 109-110
-- Session 3: middle 201-206, left 207-208, right 209-210
-- Session 4: middle 301-306, left 307-308, right 309-310
for session = 2, 4 do
    local base = (session - 1) * 100
    for i = 1, 6 do
        hl.workspace_rule({ workspace = tostring(base + i), monitor = CENTER })
    end
    for i = 7, 8 do
        hl.workspace_rule({ workspace = tostring(base + i), monitor = LEFT })
    end
    for i = 9, 10 do
        hl.workspace_rule({ workspace = tostring(base + i), monitor = RIGHT })
    end
end
