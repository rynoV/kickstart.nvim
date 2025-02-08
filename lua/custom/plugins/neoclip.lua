return {
  'AckslD/nvim-neoclip.lua',
  event = 'VimEnter',
  dependencies = {
    -- you'll need at least one of these
    { 'nvim-telescope/telescope.nvim' },
    -- {'ibhagwan/fzf-lua'},
  },
  config = function()
    require('neoclip').setup {}
    vim.keymap.set('n', '<leader>sp', require('telescope').extensions.neoclip.neoclip, { desc = 'Search clipboard history' })
  end,
}
