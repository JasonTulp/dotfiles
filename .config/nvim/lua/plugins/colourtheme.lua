-- A nice theme
return {
	'rebelot/kanagawa.nvim',
	lazy = false,
	priority = 1000,
	-- Load the colorscheme
	config = function()
		vim.cmd 'colorscheme kanagawa-dragon'
		-- Override the visual highlight to a better one
		vim.api.nvim_set_hl(0, 'Visual', { bg = '#2d4f67' })
		vim.api.nvim_set_hl(0, 'Cursor', { bg = '#2d4f67' })
		vim.api.nvim_set_hl(0, 'VisualNOS', { bg = '#2d4f67' })
	end,
}
