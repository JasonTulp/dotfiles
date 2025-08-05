-- Custom colorscheme configuration
local function setup_colorscheme()
	local set = vim.api.nvim_set_hl
	local ns = 0 -- global namespace

	-- Clear existing colorscheme
	vim.cmd 'highlight clear'
	if vim.fn.exists 'syntax_on' then
		vim.cmd 'syntax reset'
	end

	-- Set colorscheme name
	vim.g.colors_name = 'custom'

	-- UI Colors
	set(ns, 'Normal', { fg = '#d4d4d4', bg = '#212121' })
	set(ns, 'IndentBlankLineChar', { fg = '#ff0000' })
	set(ns, 'CursorLine', { bg = '#191919' })
	set(ns, 'Cursor', { fg = '#212121', bg = '#569cd6' })
	set(ns, 'Visual', { fg = '#ffffff', bg = '#353535' })
	set(ns, 'LineNr', { fg = '#60605f', bg = '#212121' })
	set(ns, 'CursorLineNr', { fg = '#f6f6f6', bg = '#212121' })
	set(ns, 'Search', { bg = '#f8e71c', fg = '#212121' })
	set(ns, 'IncSearch', { bg = '#f8e71c', fg = '#212121' })
	set(ns, 'StatusLine', { fg = '#ffffff', bg = '#101010' })
	set(ns, 'StatusLineNC', { fg = '#60605f', bg = '#101010' })
	set(ns, 'VertSplit', { fg = '#e08b0b' })
	set(ns, 'WinSeparator', { fg = '#e08b0b' })
	set(ns, 'TabLine', { fg = '#d4d4d4', bg = '#212121' })
	set(ns, 'TabLineSel', { fg = '#f6f6f6', bg = '#323232', bold = true })
	set(ns, 'TabLineFill', { bg = '#191919' })
	set(ns, 'Pmenu', { fg = '#d4d4d4', bg = '#191919' })
	set(ns, 'PmenuSel', { bg = '#353535' })
	set(ns, 'FloatBorder', { fg = '#e08b0b', bg = '#171717' })
	set(ns, 'NormalFloat', { bg = '#171717' })

	-- Syntax Colors
	set(ns, 'Comment', { fg = '#60605f', italic = true })
	set(ns, 'String', { fg = '#c3e88d' })
	set(ns, 'Keyword', { fg = '#be8bdb' })
	set(ns, 'Identifier', { fg = '#FFFFFF' }) -- variables
	set(ns, '@variable.parameter', { fg = '#f68a68' }) -- variables
	set(ns, '@variable', { fg = '#FFFFFF' }) -- variables
	-- set(ns, '@variable.member', { fg = '#f68a68' }) -- variables
	set(ns, 'Function', { fg = '#82aaff' })
	set(ns, 'Number', { fg = '#f68a68' })
	set(ns, 'Type', { fg = '#ffca69' })

	-- Types
	set(ns, '@type.builtin', { fg = '#be8bdb' })
	set(ns, '@type.parameter', { fg = '#f68a68' })
	--		set(ns, '@type.identifier', { fg = '#f68a68' })
	-- set(ns, '@constructor', { fg = '#ff0000' })
	-- set(ns, '@function.identifier', { fg = '#ff0000' })

	-- Gutter
	set(ns, 'SignColumn', { bg = '#212121' })
	set(ns, 'GitSignsAdd', { fg = '#c3e88d' })
	set(ns, 'GitSignsChange', { fg = '#ffca69' })
	set(ns, 'GitSignsDelete', { fg = '#f68a68' })

	-- Scrollbar (represented as MatchParen)
	set(ns, 'MatchParen', { fg = '#ffca69', bg = '#60605f' })

	-- SideBar / Panels
	set(ns, 'NvimTreeNormal', { bg = '#191919' })
	set(ns, 'NvimTreeWinSeparator', { fg = '#e08b0b', bg = '#191919' })
	set(ns, 'NvimTreeVertSplit', { fg = '#e08b0b' })
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
end

-- Apply the colorscheme immediately
setup_colorscheme()

-- Return empty table to satisfy lazy.nvim plugin structure
return {}
