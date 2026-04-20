--  See `:help vim.keymap.set()`

-- Hold over from emacs muscle memory
vim.keymap.set('c', '<C-g>', '<Esc>')

vim.keymap.set('n', '<leader>ay', function()
  -- Note: uses absolute path (:p), then shortens using the current directory
  -- if possible (:.). See :h filename-modifiers
  vim.fn.setreg('+', vim.fn.expand '%:p:.' .. ':' .. vim.fn.line '.' .. ':' .. vim.fn.col '.')
end, { desc = 'Copy file, line, and column to clipboard' })

-- See `:help :make_makeprg`, `:help compiler-select`, and the built in
-- compiler settings:
-- https://github.com/neovim/neovim/tree/master/runtime/compiler
vim.keymap.set('n', '<A-b>', [[<cmd>make!<CR>]], { desc = 'Build' })
vim.keymap.set('n', '<A-S-b>', [[<cmd>make<CR>]], { desc = 'Build and jump to diagnostic' })

vim.keymap.set('n', '<A-8>', [[m`/\<<C-r><C-w>\><CR>``]], { desc = 'Do `*` but stay on current match and preserve window scroll position' })
vim.keymap.set('n', '<A-3>', [[m`?\<<C-r><C-w>\><CR>``]], { desc = 'Do `#` but stay on current match and preserve window scroll position' })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
--  Note this is overridden in the `flash` plugin config
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR><cmd>echo ""<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>lQ', vim.diagnostic.setqflist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>lq', function()
  vim.diagnostic.setqflist { open = false }
end, { desc = 'Set diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>lL', vim.diagnostic.setloclist, { desc = 'Open diagnostic [L]ocation list' })
vim.keymap.set('n', '<leader>ll', function()
  vim.diagnostic.setloclist { open = false }
end, { desc = 'Set diagnostic [L]ocation list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Keybinds to make split navigation easier.
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<leader>w', function()
  vim.api.nvim_input '<C-w>'
end, { desc = '+Window' })

vim.keymap.set({ 'v', 'n', 'i' }, '<M-\\>', function()
  vim.lsp.inline_completion.enable(not vim.lsp.inline_completion.is_enabled())
  -- Exit and enter insert mode to trigger the inline completion if the
  -- completion is enabled and we're in insert mode. This is hopefully a
  -- temporary hack until the completion api is improved
  if vim.lsp.inline_completion.is_enabled() and vim.api.nvim_get_mode().mode == 'i' then
    vim.api.nvim_input '<Esc>a'
  end
end, { desc = 'Toggle inline completion' })

vim.keymap.set({ 'n', 'x', 'o' }, '<A-o>', function()
  if vim.treesitter.get_parser(nil, nil, { error = false }) then
    require('vim.treesitter._select').select_parent(vim.v.count1)
  else
    vim.lsp.buf.selection_range(vim.v.count1)
  end
end, { desc = 'Select parent treesitter node or outer incremental lsp selections' })

vim.keymap.set({ 'n', 'x', 'o' }, '<A-i>', function()
  if vim.treesitter.get_parser(nil, nil, { error = false }) then
    require('vim.treesitter._select').select_child(vim.v.count1)
  else
    vim.lsp.buf.selection_range(-vim.v.count1)
  end
end, { desc = 'Select child treesitter node or inner incremental lsp selections' })

-- From :help terminal-scrollback-pager
local function TermHl()
  vim.api.nvim_open_term(0, {})
end

vim.keymap.set('n', '<leader>mC', TermHl, { desc = 'Highlight ANSI termcodes in curbuf' })

vim.api.nvim_create_user_command('TermHl', TermHl, { desc = 'Highlights ANSI termcodes in curbuf' })

-- From :help :DiffOrig
local function diff_orig()
  vim.cmd 'vert new | set buftype=nofile | read ++edit # | 0d_ | diffthis | wincmd p | diffthis'
end

vim.api.nvim_create_user_command('DiffOrig', diff_orig, {
  desc = 'Diff with the original file',
})

vim.keymap.set('n', '<leader>ml', '<cmd>Lazy<cr>', { desc = 'Plugins' })

local util = require 'calum.util'

-- Override of the default binding that moves to the next tab if the last
-- accessed tab page no longer exists. I don't think the original binding is
-- necessary, but it is still accessible under CTRL-W g<Tab>
vim.keymap.set('n', 'g<Tab>', util.last_tab_or_next, { desc = 'Open last accessed tab or next tab' })
vim.keymap.set('n', '<C-w>Q', ':tabclose<CR>', { desc = 'Tab close' })

vim.keymap.set('n', '<leader>mf', util.open_file_in_last_tab, { desc = 'Open file at cursor in previously accessed tab page' })

-- Override these actions with repeatable wrappers
util.make_repeatable_wrappers(require('plugins.notes').haunt_prefix .. 'p', require('plugins.notes').haunt_prefix .. 'n')
-- Unsure if this actually works or if these binds just get overridden
util.make_repeatable_wrappers(']c', '[c')
util.make_repeatable_wrappers(']f', '[f')

Snacks.toggle
  .new({
    name = 'Terminal',
    get = function()
      return util.term_enabled()
    end,
    set = function(v)
      util.toggle_term()
    end,
    notify = false,
  })
  :map '<leader>tt'

--- This is used to allow toggling virtual lines completely off or only on the
--- current line, remembering the previous config when toggling it back on.
---@type vim.diagnostic.Opts.VirtualLines
local virtual_lines_conf = { current_line = false }

Snacks.toggle
  .new({
    name = 'Diagnostic show',
    get = function()
      return not not vim.diagnostic.config().virtual_lines
    end,
    set = function(v)
      vim.diagnostic.config { virtual_lines = v and virtual_lines_conf or false }
    end,
  })
  :map '<leader>tk'

Snacks.toggle
  .new({
    name = 'Diagnostic show current line',
    get = function()
      return virtual_lines_conf.current_line
    end,
    set = function(v)
      virtual_lines_conf = { current_line = v }
      if vim.diagnostic.config().virtual_lines then
        vim.diagnostic.config { virtual_lines = virtual_lines_conf }
      end
    end,
  })
  :map '<leader>tK'

Snacks.toggle
  .new({
    name = 'Codelens show (buffer)',
    get = function()
      return not not vim.lsp.codelens.is_enabled { bufnr = 0 }
    end,
    set = function(v)
      vim.lsp.codelens.enable(v, { bufnr = 0 })
    end,
  })
  :map '<leader>Ux'

Snacks.toggle
  .new({
    wk_desc = {
      enabled = 'Hide ',
      disabled = 'Show ',
    },
    name = 'Quickfix list',
    get = function()
      return (vim.fn.getqflist { winid = 1 }).winid ~= 0
    end,
    set = function(v)
      if v then
        vim.cmd 'copen'
      else
        vim.cmd 'cclose'
      end
    end,
  })
  :map '<leader>tq'

Snacks.toggle
  .new({
    wk_desc = {
      enabled = 'Hide ',
      disabled = 'Show ',
    },
    name = 'Location list',
    get = function()
      return (vim.fn.getloclist(0, { winid = 1 })).winid ~= 0
    end,
    set = function(v)
      if v then
        vim.cmd 'lopen'
      else
        vim.cmd 'lclose'
      end
    end,
  })
  :map '<leader>tl'

vim.keymap.set('n', '<leader>u', function()
  require('undotree').open {
    command = math.floor(vim.api.nvim_win_get_width(0) / 3) .. 'vnew',
  }
end, { desc = '[U]ndotree toggle' })

-- | Diffing
-- Tips for using the built-in diff:
-- If the diff is not doing what you expect, it might be because the buffer has
-- large contiguous mostly-matching regions and "linematch" is too small to
-- allow nvim to align them properly.
-- You can try increasing linematch, or try reducing the differences, for
-- example by ignoring whitespace-only changes with iwhite or iwhiteall.
-- You can also try changing from the default myers algorithm with
-- algorithm:minimal/patience/histogram.
-- If the above don't work, you can use anchors to manually line up the
-- regions.

local function make_diffopt_toggle(opt_name, key)
  Snacks.toggle
    .new({
      name = 'diffopt ' .. opt_name,
      get = function()
        return vim.api.nvim_get_option_value('diffopt', {}):find(opt_name) ~= nil
      end,
      set = function(v)
        if v then
          vim.cmd(':set diffopt+=' .. opt_name)
        else
          vim.cmd(':set diffopt-=' .. opt_name)
        end
      end,
    })
    :map(key)
end

make_diffopt_toggle('anchor', '<leader>Da')
make_diffopt_toggle('iwhite', '<leader>Dw')
make_diffopt_toggle('iwhiteall', '<leader>DW')
make_diffopt_toggle('algorithm:patience', '<leader>Dp')
make_diffopt_toggle('algorithm:histogram', '<leader>Dh')
make_diffopt_toggle('algorithm:minimal', '<leader>Dm')
make_diffopt_toggle('icase', '<leader>Di')
make_diffopt_toggle('iwhiteeol', '<leader>De')

-- User command that adds a mark to the diff anchors
-- This can be used to work around difficult to diff regions by placing marks
-- in both buffers at the locations where the diff should align, then calling
-- this command with the mark name.
vim.api.nvim_create_user_command('DiffAnchor', function(opts)
  -- It's important that setlocal is used so other diff buffers don't try to
  -- use the anchors (for example with difftool directory diffing).
  vim.cmd(":windo setlocal diffanchors+='" .. opts.args)
end, { nargs = 1, desc = 'Add a diff anchor' })

vim.keymap.set('n', '<leader>DA', ':DiffAnchor ', { desc = 'Add a diff anchor at the mark' })

-- Open line below/above with comment. Commenting empty lines is not supported
-- with built-in vim comment support, so we type a character, comment the line,
-- and delete the character.
-- We need to use :normal or switching between insert
-- and normal mode in the mapping doesn't work.
-- Note if we're in a comment already, this will instead open a line without a
-- comment (if comments are configured to be inserted automatically when
-- opening a line), which might be nice instead of using "o<C-u>"
vim.keymap.set('n', 'gco', '<Cmd>:normal oa<C-o>gcc<CR>$cl', { desc = 'Open line below with comment' })
vim.keymap.set('n', 'gcO', '<Cmd>:normal Oa<C-o>gcc<CR>$cl', { desc = 'Open line above with comment' })
-- Open comment below, go back up to current line, join the lines, and insert
-- at the end of the line
vim.keymap.set('n', 'gca', '<Cmd>:normal gco<CR>kJA', { desc = 'Add comment at end of line' })
