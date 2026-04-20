---@type LazySpec
return {
  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VeryLazy', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  {
    'folke/ts-comments.nvim',
    -- NOTE: opts.lang is a mapping from *treesitter lang* to comment configs,
    -- not from filetypes. Specifically, whatever
    -- vim.treesitter.language.get_lang returns for the filetype is the index
    -- into opts.lang.
    opts = {},
    event = 'VeryLazy',
    enabled = vim.fn.has 'nvim-0.10.0' == 1,
  },
}
