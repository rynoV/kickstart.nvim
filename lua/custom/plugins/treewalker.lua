return {
  'aaronik/treewalker.nvim',

  -- The following options are the defaults.
  -- Treewalker aims for sane defaults, so these are each individually optional,
  -- and setup() does not need to be called, so the whole opts block is optional as well.
  opts = {
    -- Whether to briefly highlight the node after jumping to it
    highlight = true,

    -- How long should above highlight last (in ms)
    highlight_duration = 250,

    -- The color of the above highlight. Must be a valid vim highlight group.
    -- (see :h highlight-group for options)
    highlight_group = 'CursorLine',
  },

  keys = {
    { '<C-k>', '<cmd>Treewalker Up<cr>', silent = true, mode = { 'n', 'v' } },
    { '<C-j>', '<cmd>Treewalker Down<cr>', silent = true, mode = { 'n', 'v' } },
    { '<C-h>', '<cmd>Treewalker Left<cr>', silent = true, mode = { 'n', 'v' } },
    { '<C-l>', '<cmd>Treewalker Right<cr>', silent = true, mode = { 'n', 'v' } },
    { '<C-A-k>', '<cmd>Treewalker SwapUp<cr>', silent = true },
    { '<C-A-j>', '<cmd>Treewalker SwapDown<cr>', silent = true },
    { '<C-A-h>', '<cmd>Treewalker SwapLeft<cr>', silent = true },
    { '<C-A-l>', '<cmd>Treewalker SwapRight<cr>', silent = true },
  },
}
