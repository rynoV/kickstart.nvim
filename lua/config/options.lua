-- See `:help vim.opt`
-- For more options, you can see `:help option-list`

-- Allow local config files per-directory. :h 'exrc'
vim.opt.exrc = true

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

vim.g.health = { style = 'float' }

-- Make line numbers default
vim.opt.number = true
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
--
-- On wsl, my solution for the clipboard was to install win32yank in windows (eg with winget). Also needed to ensure xclip wasn't installed on the linux distro.
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Folding is enabled by default, but no folds are closed. Use zM to get a file
-- outline, or za to fold at the cursor, and zi to toggle folding.
vim.opt.foldenable = true
vim.opt.foldlevel = 9999
-- Use syntax highlighting for showing the first line of a closed fold
-- https://github.com/neovim/neovim/pull/20750
-- Decided against this for now because it makes diffs harder to read (can't
-- differentiate folded lines from added/changed lines)
-- vim.opt.foldtext = ''
-- vim.opt.fillchars = 'fold: '

-- Show a border for floating windows
vim.opt.winborder = 'rounded'

-- Behaviour I'm used to when closing tabs
vim.opt.tabclose = { 'uselast', 'left' }

vim.opt.completeopt:append { 'noinsert', 'popup' }

-- Ignore leading '-' for numbers when using C-a or C-x
vim.opt.nrformats:append { 'unsigned' }

vim.opt.conceallevel = 2

-- Lint treesitter queries :help ft-query-plugin
vim.g.query_lint_on = { 'InsertLeave', 'TextChanged' }

vim.lsp.codelens.enable()
vim.lsp.on_type_formatting.enable()
vim.diagnostic.config { virtual_lines = false }

vim.opt.diffopt:remove 'inline:char'

vim.opt.diffopt:append {
  -- Using the new nvim.difftool with directories and anchors breaks things if
  -- hiddenoff is not set
  'hiddenoff',
  'vertical',
  'inline:word',
  'anchor',
}

vim.cmd.packadd { 'nvim.difftool', bang = not vim.v.vim_did_init }
vim.cmd.packadd { 'nvim.undotree', bang = not vim.v.vim_did_init }
