-- Side-by-side git diffs and file history
return {
	'sindrets/diffview.nvim',
	cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
	keys = {
		{ '<leader>do', '<cmd>DiffviewOpen<cr>', desc = 'Diffview Open' },
		{ '<leader>df', '<cmd>DiffviewFileHistory %<cr>', desc = 'File History' },
		{ '<leader>dh', '<cmd>DiffviewFileHistory<cr>', desc = 'Branch History' },
		{ '<leader>dc', '<cmd>DiffviewClose<cr>', desc = 'Diffview Close' },
		{ '<leader>dm', '<cmd>DiffviewOpen main<cr>', desc = 'Diff main' },
		{ '<leader>dp', '<cmd>DiffviewOpen origin/main...HEAD<cr>', desc = 'Diff PR (origin/main...HEAD)' },
	},
	opts = {
		enhanced_diff_hl = true,
		use_icons = true,
	},
}
