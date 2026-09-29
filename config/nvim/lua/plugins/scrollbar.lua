return {
	'petertriho/nvim-scrollbar',
	event = 'VeryLazy',
	config = function()
		require('scrollbar').setup {
			handle = {
				color = '#444444', -- customize handle color
			},
			marks = {
				GitAdd = { text = '─', color = '#a6e22e' },
				GitChange = { text = '─', color = '#ffca69' },
				GitDelete = { text = '‾', color = '#f68a68' },
			},
			handlers = {
				gitsigns = true, -- <-- this enables Git integration
			},
		}
	end,
	dependencies = {
		'lewis6991/gitsigns.nvim', -- required for git integration
	},
}
