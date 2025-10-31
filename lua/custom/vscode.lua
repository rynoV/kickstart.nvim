-- Based on the LazyVim vscode extra:
-- https://github.com/LazyVim/LazyVim/blob/064e61058b6bbaef02a6143662628d105695b8e5/lua/lazyvim/plugins/extras/vscode.lua
if not vim.g.vscode then
  return {}
end

local vscode = require 'vscode'
vim.notify = vscode.notify

local enabled = {
  'dial.nvim',
  'flit.nvim',
  'lazy.nvim',
  'leap.nvim',
  'mini.extra',
  'mini.ai',
  'mini.comment',
  'mini.move',
  'mini.pairs',
  'mini.surround',
  'nvim-next',
  'nvim-treesitter',
  'nvim-treesitter-textobjects',
  'nvim-ts-context-commentstring',
  'snacks.nvim',
  'ts-comments.nvim',
  'vim-repeat',
  'yanky.nvim',
}

local Config = require 'lazy.core.config'
Config.options.checker.enabled = false
Config.options.change_detection.enabled = false
Config.options.defaults.cond = function(plugin)
  ---@diagnostic disable-next-line: undefined-field
  return vim.tbl_contains(enabled, plugin.name) or plugin.vscode
end

return {
  {
    'snacks.nvim',
    opts = {
      bigfile = { enabled = false },
      dashboard = { enabled = false },
      indent = { enabled = false },
      input = { enabled = false },
      notifier = { enabled = false },
      picker = { enabled = false },
      quickfile = { enabled = false },
      scroll = { enabled = false },
      statuscolumn = { enabled = false },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { highlight = { enable = false } },
  },
}
