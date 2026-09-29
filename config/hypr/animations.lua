hl.config({ animations = { enabled = true } })

hl.curve("smooth", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.0 } } })
hl.curve("snappy", { type = "bezier", points = { { 0.2, 0.9 }, { 0.2, 1.0 } } })

hl.animation({ leaf = "windowsMove", enabled = true, speed = 2, bezier = "snappy" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 3, bezier = "smooth", style = "slide" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 3, bezier = "smooth", style = "slide" })
hl.animation({ leaf = "fade",        enabled = true, speed = 3, bezier = "smooth" })
hl.animation({ leaf = "border",      enabled = true, speed = 2, bezier = "smooth" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 4, bezier = "smooth", style = "slide" })
