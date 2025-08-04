-- File: ~/.config/nvim/lua/material_darker_theme.lua

local set = vim.api.nvim_set_hl
local ns = 0 -- global namespace

-- UI Colors
set(ns, 'Normal', { fg = '#d4d4d4', bg = '#212121' })
set(ns, 'CursorLine', { bg = '#191919' })
set(ns, 'Cursor', { fg = '#212121', bg = '#569cd6' })
set(ns, 'Visual', { bg = '#353535' })
set(ns, 'LineNr', { fg = '#60605f', bg = '#212121' })
set(ns, 'CursorLineNr', { fg = '#f6f6f6', bg = '#212121' })
set(ns, 'Search', { bg = '#f8e71c', fg = '#212121' })
set(ns, 'IncSearch', { bg = '#f8e71c', fg = '#212121' })
set(ns, 'StatusLine', { fg = '#ffffff', bg = '#101010' })
set(ns, 'StatusLineNC', { fg = '#60605f', bg = '#101010' })
set(ns, 'VertSplit', { fg = '#e08b0b76' })
set(ns, 'WinSeparator', { fg = '#e08b0b76' })
set(ns, 'TabLine', { fg = '#d4d4d4', bg = '#212121' })
set(ns, 'TabLineSel', { fg = '#f6f6f6', bg = '#323232', bold = true })
set(ns, 'TabLineFill', { bg = '#191919' })
set(ns, 'Pmenu', { fg = '#d4d4d4', bg = '#191919' })
set(ns, 'PmenuSel', { bg = '#353535' })
set(ns, 'FloatBorder', { fg = '#e08b0b76', bg = '#171717' })
set(ns, 'NormalFloat', { bg = '#171717' })

-- Syntax Colors
set(ns, 'Comment', { fg = '#60605f', italic = true })
set(ns, 'String', { fg = '#c3e88d' })
set(ns, 'Keyword', { fg = '#be8bdb' })
set(ns, 'Identifier', { fg = '#e8f9f9' }) -- variables
set(ns, 'Function', { fg = '#82aaff' })
set(ns, 'Number', { fg = '#f68a68' })
set(ns, 'Type', { fg = '#ffca69' })

-- Gutter
set(ns, 'SignColumn', { bg = '#212121' })
set(ns, 'GitSignsAdd', { fg = '#a6e22e' })
set(ns, 'GitSignsChange', { fg = '#ffca69' })
set(ns, 'GitSignsDelete', { fg = '#f68a68' })

-- Scrollbar (represented as MatchParen)
set(ns, 'MatchParen', { bg = '#ff9b0566' })

-- SideBar / Panels
set(ns, 'NvimTreeNormal', { bg = '#191919' })
set(ns, 'NvimTreeWinSeparator', { fg = '#e08b0b76', bg = '#191919' })
set(ns, 'NvimTreeVertSplit', { fg = '#e08b0b76' })
set(ns, 'NvimTreeNormalNC', { bg = '#191919' })

-- Terminal
set(ns, 'TermNormal', { bg = '#191919' })
set(ns, 'TermCursor', { fg = '#569cd6' })

-- Title bar
set(ns, 'Title', { fg = '#ffffff', bg = '#202020' })

-- Section headers
set(ns, 'Directory', { fg = '#e08a0b', bold = true })

-- Panel
set(ns, 'QuickFixLine', { bg = '#171717' })
