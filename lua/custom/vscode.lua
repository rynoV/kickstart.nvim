-- Lua function to open current file in VS Code at the current line and column
vim.keymap.set('n', '<leader>v', function()
  local r, c = unpack(vim.api.nvim_win_get_cursor(0))
  vim.cmd('!code -g ' .. vim.fn.expand '%' .. ':' .. r .. ':' .. c)
end, { desc = '[O]pen in [V]S Code' })

-- Based on the LazyVim vscode extra:
-- https://github.com/LazyVim/LazyVim/blob/064e61058b6bbaef02a6143662628d105695b8e5/lua/lazyvim/plugins/extras/vscode.lua
if not vim.g.vscode then
  return {}
end

-- Smaller timeout lengths seems to make it impossible for me to hit some keybindings in time
vim.opt.timeoutlen = 1000

local vscode = require 'vscode'
vim.notify = function(msg, log_level, opts)
  -- vscode doesn't have a notification lower than info afaict, so we avoid
  -- noise like this
  if log_level >= vim.log.levels.INFO then
    vscode.notify(msg, log_level, opts)
  end
end

--- vscode-neovim defines some overrides here:
--- https://github.com/vscode-neovim/vscode-neovim/blob/a54bbfbe79aeee512a239c8809019b2c9547d3e3/runtime/vscode/overrides/
---
--- We shim the built-in vim.keymap functions to avoid overwriting
--- vscode-neovim. It's necessary to shim keymap.del as well because lazy.nvim
--- calls this as part of its setup.
local vscode_neovim_builtin_bindings = {
  'K',
  'gh',
  'gf',
  '<C-]>',
  'gO',
  'gF',
  'gD',
  'gH',
  'gd',
  '<C-w>gf',
  '<C-w>gd',
  'z=',
  'ZZ',
  'ZQ',
  '<C-o>',
  '<C-i>',
  'g0',
  'g$',
  'gk',
  'gj',
  'z<CR>',
  'zt',
  'z.',
  'zz',
  'z-',
  'zb',
  'H',
  'M',
  'L',
  'gt',
  'gT',
  -- There's a bunch of <C-w> window commands, but I can't be bothered to write them out because I don't overwrite them
}

local keymap_set_orig = vim.keymap.set
local keymap_del_orig = vim.keymap.del

---@diagnostic disable-next-line: duplicate-set-field
vim.keymap.set = function(mode, lhs, rhs, opts)
  if vim.tbl_contains(vscode_neovim_builtin_bindings, lhs) then
    vim.notify('Skipping overwrite of built-in vscode-neovim binding ' .. lhs, vim.log.levels.DEBUG)
    return
  end
  keymap_set_orig(mode, lhs, rhs, opts)
end

---@diagnostic disable-next-line: duplicate-set-field
vim.keymap.del = function(modes, lhs, opts)
  if vim.tbl_contains(vscode_neovim_builtin_bindings, lhs) then
    vim.notify('Skipping deletion of built-in vscode-neovim binding ' .. lhs, vim.log.levels.DEBUG)
    return
  end
  keymap_del_orig(modes, lhs, opts)
end

local enabled = {
  'dial.nvim',
  'flit.nvim',
  'lazy.nvim',
  'leap.nvim',
  'flash.nvim',
  'mini.extra',
  'mini.ai',
  'mini.comment',
  'mini.move',
  'mini.pairs',
  'mini.surround',
  'mini.operators',
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

-- Add some vscode specific keymaps
vim.api.nvim_create_autocmd('User', {
  callback = function()
    -- VSCode-specific keymaps for search and navigation
    vim.keymap.set('n', '<leader><space>', '<cmd>Find<cr>')
    vim.keymap.set('n', '<leader>/', function()
      vscode.call 'workbench.action.findInFiles'
    end)
    vim.keymap.set('n', '<leader>ss', function()
      vscode.call 'workbench.action.gotoSymbol'
    end)
    vim.keymap.set('n', '<leader>sS', function()
      vscode.call 'workbench.action.showAllSymbols'
    end)
    vim.keymap.set('n', '<leader>bd', function()
      vscode.call 'workbench.action.closeActiveEditor'
    end)

    -- Toggle VS Code integrated terminal
    vim.keymap.set('n', '<leader>tt', function()
      vscode.call 'workbench.action.terminal.toggleTerminal'
    end)

    vim.keymap.set({ 'n', 'x' }, '<leader>i', function()
      vscode.with_insert(function()
        vscode.call 'inlineChat.start'
      end)
    end)
  end,
})

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
