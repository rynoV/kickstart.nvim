--  See `:help lua-guide-autocommands`

-- We set up a group of auto-commands that makes working with terminals within
-- neovim a bit nicer. Whenever a running terminal buffer is focused, we switch
-- to terminal mode automatically. Emacs terminals also disable line numbers.
-- There is a related customization in the mini.statusline config that clears
-- the statusline for the emacs window
local emacs_focus_group = vim.api.nvim_create_augroup('calum-emacs-focus', { clear = true })

local tabs = require 'calum.tabs'
local emacs = require 'calum.emacs'
local emacs_window_options = {}
local pending_new_window_options

local function is_emacs_window(win)
  return tabs.is_emacs_window(win)
end

local function is_terminal_window(win)
  return vim.api.nvim_win_is_valid(win)
    and vim.api.nvim_win_get_config(win).relative == ''
    and vim.bo[vim.api.nvim_win_get_buf(win)].buftype == 'terminal'
end

local function enter_emacs_window(win)
  if not is_emacs_window(win) then
    return
  end

  if not emacs_window_options[win] then
    emacs_window_options[win] = {
      number = vim.wo[win].number,
      relativenumber = vim.wo[win].relativenumber,
    }
  end

  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
end

local function enter_terminal_window(win)
  if not is_terminal_window(win) then
    return
  end

  local buf = vim.api.nvim_win_get_buf(win)
  if vim.b[buf].calum_terminal_state ~= 'running' and not is_emacs_window(win) then
    return
  end

  if vim.fn.mode() ~= 't' then
    vim.cmd.startinsert()
  end
end

local function configure_terminal_window(win)
  vim.schedule(function()
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_get_current_win() == win then
      enter_emacs_window(win)
      enter_terminal_window(win)
    end
  end)
end

local function leave_emacs_window(win)
  local options = emacs_window_options[win]
  if not options then
    return
  end

  pending_new_window_options = options
  if vim.api.nvim_win_is_valid(win) then
    vim.wo[win].number = options.number
    vim.wo[win].relativenumber = options.relativenumber
  end
  emacs_window_options[win] = nil
end

vim.api.nvim_create_autocmd('WinEnter', {
  desc = 'Configure focused terminal window',
  group = emacs_focus_group,
  callback = function()
    pending_new_window_options = nil
    configure_terminal_window(vim.api.nvim_get_current_win())
  end,
})

vim.api.nvim_create_autocmd('WinLeave', {
  desc = 'Restore window options after leaving Emacs terminal',
  group = emacs_focus_group,
  callback = function()
    leave_emacs_window(vim.api.nvim_get_current_win())
  end,
})

vim.api.nvim_create_autocmd('WinNew', {
  desc = 'Restore inherited options in new windows after Emacs',
  group = emacs_focus_group,
  callback = function()
    if pending_new_window_options then
      local win = vim.api.nvim_get_current_win()
      vim.wo[win].number = pending_new_window_options.number
      vim.wo[win].relativenumber = pending_new_window_options.relativenumber
      pending_new_window_options = nil
    end
  end,
})

vim.api.nvim_create_autocmd('WinClosed', {
  desc = 'Discard closed Emacs window state',
  group = emacs_focus_group,
  callback = function(event)
    emacs_window_options[tonumber(event.match)] = nil
  end,
})

vim.api.nvim_create_autocmd('TabEnter', {
  desc = 'Refresh Magit when entering the Emacs tab',
  group = emacs_focus_group,
  callback = function()
    if tabs.is_emacs() then
      emacs.refresh_magit_status()
    end
  end,
})

vim.api.nvim_create_autocmd('ColorScheme', {
  desc = 'Color scheme customization',
  group = vim.api.nvim_create_augroup('calum-color-scheme', { clear = true }),
  callback = function()
    -- These are mostly based on the fsharp lsp/treesitter defaults
    vim.api.nvim_set_hl(0, '@lsp.type.module', { link = '@lsp.type.class' })
    vim.api.nvim_set_hl(0, '@lsp.type.variable', { link = '@variable' })
    -- Parameters don't need a different colour from variables
    vim.api.nvim_set_hl(0, '@variable.parameter', { link = '@variable' })
    vim.api.nvim_set_hl(0, '@keyword.import', { link = '@keyword' })
    local original_diag_unnecessary = vim.api.nvim_get_hl(0, { name = 'DiagnosticUnnecessary' })
    vim.api.nvim_set_hl(0, 'DiagnosticUnnecessary', { underdotted = true })
    -- Snacks dim uses this highlight group by default, which usually looks
    -- good so we avoid overriding it for snack dim only
    ---@diagnostic disable-next-line: param-type-mismatch
    vim.api.nvim_set_hl(0, 'SnacksDim', original_diag_unnecessary)
    -- A little more readable than the default "NonText" link
    vim.api.nvim_set_hl(0, 'SnacksDebugPrint', { link = 'Comment' })
    vim.api.nvim_set_hl(0, 'TabLineFill', {})
    -- The default highlights aren't very legible with my theme, comment is better
    vim.api.nvim_set_hl(0, 'ComplHint', { link = 'Comment' }) -- lsp inline completion
    vim.api.nvim_set_hl(0, 'LspCodeLens', { link = 'Comment' })
  end,
})

-- From :h vim.hl.on_yank()
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight on yank',
  group = vim.api.nvim_create_augroup('calum-highlight-on-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank { higroup = 'Search', timeout = 300 }
  end,
})

vim.api.nvim_create_autocmd('TermOpen', {
  desc = 'Terminal specific options',
  group = vim.api.nvim_create_augroup('calum-terminal-settings', { clear = true }),
  callback = function(event)
    vim.b[event.buf].calum_terminal_state = 'unknown'
    vim.opt_local.relativenumber = true
    vim.opt_local.scrollback = 100000
    configure_terminal_window(vim.api.nvim_get_current_win())
  end,
})

-- See :help terminal-osc7
--
-- Implement extraction and tracking of the current working directory from osc7
-- sequences from terminals. Each terminal has its cwd saved in the buffer
-- local variable calum_terminal_cwd, which is automatically updated as long as
-- the terminal's process emits osc7 sequences (like fish shell)
local function terminal_cwd_from_osc7(sequence)
  local host, path = sequence:match '^\027%]7;file://([^/]*)(/.*)$'
  if not path then
    return nil
  end

  host = vim.uri_decode(host):lower()
  local hostname = vim.uri_decode(vim.uv.os_gethostname()):lower()
  if host ~= '' and host ~= 'localhost' and host ~= hostname then
    return nil
  end

  path = vim.uri_decode(path)
  local stat = vim.uv.fs_stat(path)
  if not stat or stat.type ~= 'directory' then
    return nil
  end

  return vim.fs.normalize(vim.fs.abspath(path))
end

if vim.fn.exists '##TermRequest' == 1 then
  vim.api.nvim_create_autocmd('TermRequest', {
    group = vim.api.nvim_create_augroup('calum-terminal-state', { clear = true }),
    callback = function(event)
      if vim.bo[event.buf].buftype ~= 'terminal' then
        return
      end

      local marker = event.data.sequence:match '^\027%]133;([ABCD])'
      if marker == 'A' or marker == 'B' or marker == 'D' then
        vim.b[event.buf].calum_terminal_state = 'prompt'
      elseif marker == 'C' then
        vim.b[event.buf].calum_terminal_state = 'running'
      end
    end,
  })

  vim.api.nvim_create_autocmd('TermRequest', {
    group = vim.api.nvim_create_augroup('calum-terminal-cwd', { clear = true }),
    callback = function(event)
      local sequence = event.data.sequence
      if vim.bo[event.buf].buftype ~= 'terminal' or not vim.startswith(sequence, '\027]7;') then
        return
      end

      local cwd = terminal_cwd_from_osc7(sequence)
      if cwd then
        vim.b[event.buf].calum_terminal_cwd = cwd
      end
    end,
  })
end

vim.api.nvim_create_autocmd('TermClose', {
  desc = 'Clear terminal state after the job exits',
  group = vim.api.nvim_create_augroup('calum-terminal-state-close', { clear = true }),
  callback = function(event)
    vim.b[event.buf].calum_terminal_state = 'exited'
  end,
})
