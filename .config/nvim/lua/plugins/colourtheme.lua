-- A nice theme
return {
    'rebelot/kanagawa.nvim',
    lazy = false,
    priority = 1000,
    -- Load the colorscheme
    config = function()
      vim.cmd("colorscheme kanagawa-dragon")
    end
}


