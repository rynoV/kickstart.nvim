--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

What is Kickstart?

  Kickstart.nvim is *not* a distribution.

  Kickstart.nvim is a starting point for your own configuration.
    The goal is that you can read every line of code, top-to-bottom, understand
    what your configuration is doing, and modify it to suit your needs.

    Once you've done that, you can start exploring, configuring and tinkering to
    make Neovim your own! That might mean leaving Kickstart just the way it is for a while
    or immediately breaking it into modular pieces. It's up to you!

    If you don't know anything about Lua, I recommend taking some time to read through
    a guide. One possible example which will only take 10-15 minutes:
      - https://learnxinyminutes.com/docs/lua/

    After understanding a bit more about Lua, you can use `:help lua-guide` as a
    reference for how Neovim integrates Lua.
    - :help lua-guide
    - (or HTML version): https://neovim.io/doc/user/lua-guide.html

Kickstart Guide:

  TODO: The very first thing you should do is to run the command `:Tutor` in Neovim.

    If you don't know what this means, type the following:
      - <escape key>
      - :
      - Tutor
      - <enter key>

    (If you already know the Neovim basics, you can skip this step.)

  Once you've completed that, you can continue working through **AND READING** the rest
  of the kickstart init.lua.

  Next, run AND READ `:help`.
    This will open up a help window with some basic information
    about reading, navigating and searching the builtin help documentation.

    This should be the first place you go to look when you're stuck or confused
    with something. It's one of my favorite Neovim features.

    MOST IMPORTANTLY, we provide a keymap "<space>sh" to [s]earch the [h]elp documentation,
    which is very useful when you're not exactly sure of what you're looking for.

  I have left several `:help X` comments throughout the init.lua
    These are hints about where to find more information about the relevant settings,
    plugins or Neovim features used in Kickstart.

   NOTE: Look for lines like this

    Throughout the file. These are for you, the reader, to help you understand what is happening.
    Feel free to delete them once you know what you're doing, but they should serve as a guide
    for when you are first encountering a few different constructs in your Neovim config.

If you experience any errors while trying to install kickstart, run `:checkhealth` for more info.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now! :)
--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
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

-- Enable break indent
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

-- Show a border for floating windows
vim.opt.winborder = 'rounded'

-- Behaviour I'm used to when closing tabs
vim.opt.tabclose = { 'uselast', 'left' }

vim.opt.completeopt:append { 'noinsert', 'popup' }

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Hold over from emacs muscle memory
vim.keymap.set('c', '<C-g>', '<Esc>')

vim.keymap.set('n', 'gV', '`[v`]', { desc = 'Select last yank/paste' })
vim.keymap.set('n', '<A-8>', [[m`/\<<C-r><C-w>\><CR>``]], { desc = 'Do `*` but stay on current match and preserve window scroll position' })
vim.keymap.set('n', '<A-3>', [[m`?\<<C-r><C-w>\><CR>``]], { desc = 'Do `#` but stay on current match and preserve window scroll position' })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
--  Note this is overridden in the `flash` plugin config
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

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

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<leader>w', '<C-w>')

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd('ColorScheme', {
  desc = 'Color scheme customization',
  group = vim.api.nvim_create_augroup('calum-color-scheme', { clear = true }),
  callback = function()
    -- These are mostly based on the fsharp lsp/treesitter defaults
    vim.api.nvim_set_hl(0, '@lsp.type.module', { link = '@lsp.type.class' })
    vim.api.nvim_set_hl(0, '@lsp.type.variable', { link = '@variable' })
    vim.api.nvim_set_hl(0, '@keyword.import', { link = '@keyword' })
    vim.api.nvim_set_hl(0, 'DiagnosticUnnecessary', { underdotted = true })
    vim.api.nvim_set_hl(0, 'TabLineFill', {})
  end,
})

vim.api.nvim_create_autocmd('TermOpen', {
  desc = 'Terminal specific options',
  group = vim.api.nvim_create_augroup('calum-terminal-settings', { clear = true }),
  callback = function()
    vim.opt_local.relativenumber = true
  end,
})

-- From :help :DiffOrig
local function diff_orig()
  vim.cmd 'vert new | set buftype=nofile | read ++edit # | 0d_ | diffthis | wincmd p | diffthis'
end

vim.api.nvim_create_user_command('DiffOrig', diff_orig, {
  desc = 'Diff with the original file',
})

local toggle_qf = function()
  if (vim.fn.getqflist { winid = 1 }).winid == 0 then
    vim.cmd 'copen'
  else
    vim.cmd 'cclose'
  end
end

local toggle_loc = function()
  if (vim.fn.getloclist(0, { winid = 1 })).winid == 0 then
    vim.cmd 'lopen'
  else
    vim.cmd 'lclose'
  end
end

vim.keymap.set('n', '<leader>tq', toggle_qf, { desc = 'toggle quickfix list' })
vim.keymap.set('n', '<leader>tl', toggle_loc, { desc = 'toggle location list' })

--- This is used to allow toggling virtual lines completely off or only on the
--- current line, remembering the previous config when toggling it back on.
---@type vim.diagnostic.Opts.VirtualLines
local virtual_lines_conf = { current_line = false }

vim.diagnostic.config { virtual_lines = false }

vim.keymap.set('n', '<leader>tK', function()
  local new_config = not virtual_lines_conf.current_line
  virtual_lines_conf = { current_line = new_config }
  -- Only update the active config if virtual lines are enabled
  if vim.diagnostic.config().virtual_lines then
    vim.diagnostic.config { virtual_lines = virtual_lines_conf }
  end
end, { desc = 'Toggle diagnostic show only on current line' })

vim.keymap.set('n', '<leader>tk', function()
  local new_config = not vim.diagnostic.config().virtual_lines
  vim.diagnostic.config { virtual_lines = new_config and virtual_lines_conf or false }
end, { desc = 'Toggle diagnostic show' })

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

vim.keymap.set('n', '<leader>ml', '<cmd>Lazy<cr>', { desc = 'Plugins' })

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({
  -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  -- NOTE: Plugins can also be added by using a table,
  -- with the first argument being the link and the following
  -- keys can be used to configure plugin behavior/loading/etc.
  --
  -- Use `opts = {}` to force a plugin to be loaded.
  --

  -- NOTE: Plugins can also be configured to run Lua code when they are loaded.
  --
  -- This is often very useful to both group configuration, as well as handle
  -- lazy loading plugins that don't need to be loaded immediately at startup.
  --
  -- For example, in the following configuration, we use:
  --  event = 'VimEnter'
  --
  -- which loads which-key before all the UI elements are loaded. Events can be
  -- normal autocommands events (`:help autocmd-events`).
  --
  -- Then, because we use the `opts` key (recommended), the configuration runs
  -- after the plugin has been loaded as `require(MODULE).setup(opts)`.

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    opts = {
      -- delay between pressing a key and opening which-key (milliseconds)
      -- this setting is independent of vim.opt.timeoutlen
      delay = 0,
      icons = {
        -- set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
        -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
        -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },

      -- Document existing key chains
      spec = {
        { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>td', group = '[D]ebug' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { '<leader>m', group = '[M]isc' },
        { '<leader>mg', group = '[G]it' },
        { '<leader>ms', group = '[S]nippets' },
        { '<leader>w', proxy = '<c-w>', group = '[W]indows' },
        { '<leader>b', group = '[B]uffers' },
        { '<leader>l', group = '[L]ists' },
      },
    },
  },

  -- NOTE: Plugins can specify dependencies.
  --
  -- The dependencies are proper plugin specifications as well - anything
  -- you do for a plugin at the top level, you can do for a dependency.
  --
  -- Use the `dependencies` key to specify the dependencies of a particular plugin

  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      {
        'nvim-lua/plenary.nvim',
        config = function()
          require('plenary.filetype').add_file 'fsharp'
        end,
      },
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },

      -- https://github.com/danielfalk/smart-open.nvim
      -- Note: requires sqlite 3 to be installed. See below for Windows install instructions
      -- Allows for intelligently searching for open buffers and files to open
      {
        'danielfalk/smart-open.nvim',
        branch = '0.3.x',
        cond = function()
          -- On Windows, go to https://www.sqlite.org/download.html and extract to the below directory in the config folder
          if vim.fn.has 'win64' == 1 then
            local sqlite_dll_path = vim.fn.stdpath 'config' .. '/sqlite/sqlite3.dll'
            if vim.fn.filereadable(sqlite_dll_path) == 1 then
              vim.g.sqlite_clib_path = sqlite_dll_path
              return true
            end
          end

          if vim.fn.executable 'sqlite3' == 1 then
            return true
          else
            vim.notify('Sqlite3 is not installed. Telescope smart open may not work properly.', vim.log.levels.WARN)
            return false
          end
        end,
        config = function()
          require('telescope').load_extension 'smart_open'
        end,
        dependencies = {
          'kkharji/sqlite.lua',
        },
      },
    },
    config = function()
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      local actions = require 'telescope.actions'
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        -- defaults = {
        --   mappings = {
        --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        --   },
        -- },
        pickers = {
          buffers = {
            mappings = {
              i = {
                ['<c-d>'] = actions.delete_buffer + actions.move_to_top,
              },
            },
          },
        },
        defaults = {
          mappings = {
            i = {
              -- Don't go to normal mode, just close
              ['<esc>'] = actions.close,
              ['<C-g>'] = actions.close,
              -- Delete to start of line instead of scrolling
              ['<C-u>'] = false,
            },
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
          smart_open = {
            match_algorithm = 'fzf',
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- https://github.com/nvim-telescope/telescope.nvim/issues/2497#issuecomment-1676551193
      local function getVisualSelection()
        vim.cmd 'noau normal! "vy"'
        local text = vim.fn.getreg 'v'
        vim.fn.setreg('v', {})

        text = string.gsub(text, '\n', '')
        if #text > 0 then
          return text
        else
          return ''
        end
      end

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      local custom = require 'custom.telescope_config'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('v', '<leader>sh', function()
        builtin.help_tags { default_text = getVisualSelection() }
      end, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      -- Default is to try searching all files tracked by git, fallback to default search if not in git
      vim.keymap.set('n', '<leader>sf', custom.project_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sF', builtin.find_files, { desc = '[S]earch all [F]iles' })
      vim.keymap.set('v', '<leader>sf', function()
        custom.project_files { default_text = getVisualSelection() }
      end, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>s*', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('v', '<leader>s*', function()
        builtin.grep_string {
          default_text = getVisualSelection(),
        }
      end, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', function()
        builtin.oldfiles { only_cwd = true }
      end, { desc = '[S]earch Recent Files in CWD' })
      vim.keymap.set('n', '<leader>s>', builtin.oldfiles, { desc = '[S]earch All Recent Files' })
      vim.keymap.set('n', '<leader>sb', function()
        builtin.buffers { sort_mru = true, sort_lastused = true }
      end, { desc = '[S]earch [B]uffers' })
      vim.keymap.set('n', '<leader><leader>', function()
        require('telescope').extensions.smart_open.smart_open()
      end, { desc = '[ ] Smart open' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          previewer = true,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
      vim.keymap.set('n', '<leader>sc', function()
        require('telescope.builtin').find_files {
          ---@diagnostic disable-next-line: param-type-mismatch
          cwd = vim.fs.joinpath(vim.fn.stdpath 'data', 'lazy'),
        }
      end, { desc = '[Search] plugin [c]ode' })
    end,
  },

  -- LSP Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { 'williamboman/mason.nvim', keys = {
        { '<leader>mm', '<cmd>Mason<cr>', desc = 'Tools', mode = 'n' },
      }, opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      {
        'j-hui/fidget.nvim',
        opts = {
          progress = {
            suppress_on_insert = true,
            ignore = {
              function(msg)
                -- FSAutocomplete is noisy with the "checking" messages, and it also seems to cause cursor flickering for some reason
                return msg.lsp_client.name == 'fsautocomplete' and string.find(string.lower(msg.title or ''), 'checking')
              end,
            },
          },
          notification = {
            window = {
              -- Make the window look nicer assuming theme has a transparent background
              winblend = 0,
            },
          },
        },
      },
    },
    config = function()
      -- Brief aside: **What is LSP?**
      --
      -- LSP is an initialism you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>sw', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end

          if client and client:supports_method 'textDocument/foldingRange' then
            local win = vim.api.nvim_get_current_win()
            vim.wo[win][0].foldmethod = 'expr'
            vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
          end
        end,
      })

      -- Change diagnostic symbols in the sign column (gutter)
      -- if vim.g.have_nerd_font then
      --   local signs = { ERROR = '', WARN = '', INFO = '', HINT = '' }
      --   local diagnostic_signs = {}
      --   for type, icon in pairs(signs) do
      --     diagnostic_signs[vim.diagnostic.severity[type]] = icon
      --   end
      --   vim.diagnostic.config { signs = { text = diagnostic_signs } }
      -- end

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        -- clangd = {},
        -- gopls = {},
        -- pyright = {},
        -- rust_analyzer = {},
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`ts_ls`) will work just fine
        ts_ls = {},
        --

        lua_ls = {
          -- cmd = { ... },
          -- filetypes = { ... },
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      local is_windows = vim.fn.has 'win64' == 1
      local is_macos = vim.fn.has 'mac' == 1
      local is_linux = vim.fn.has 'unix' == 1 and not is_macos
      if is_linux or is_macos then
        servers.rust_analyzer = {}
      end

      if is_linux or is_windows then
        servers.fsautocomplete = {
          settings = {
            FSharp = {
              -- This is false by default, but useful for importing from other modules/namespaces
              ExternalAutocomplete = true,
              -- Default is "this"
              InterfaceStubGenerationObjectIdentifier = 'x',
              -- Default is true, but often I use longer names for clarity
              SimplifyNameAnalyzer = false,
            },
          },
        }
      end

      -- Ensure the servers and tools above are installed
      --
      -- To check the current status of installed tools and/or manually install
      -- other tools, you can run
      --    :Mason
      --
      -- You can press `g?` for help in this menu.
      --
      -- `mason` had to be setup earlier: to configure its options see the
      -- `dependencies` table for `nvim-lspconfig` above.
      --
      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_filter(function(v)
        -- We don't want rust_analyzer to be automatically installed
        return v ~= 'rust_analyzer'
      end, vim.tbl_keys(servers or {}))
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
        'prettier',
      })

      if is_windows then
        vim.list_extend(ensure_installed, {
          -- 'fantomas', -- F# formatting
        })
      end

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      local server_setup = function(server_name)
        local server = servers[server_name] or {}
        -- This handles overriding only values explicitly passed
        -- by the server configuration above. Useful when disabling
        -- certain features of an LSP (for example, turning off formatting for ts_ls)
        require('lspconfig')[server_name].setup(server)
      end

      require('mason-lspconfig').setup {
        handlers = { server_setup },
      }

      server_setup 'rust_analyzer'
    end,
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = true,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        local lsp_format_opt
        if disable_filetypes[vim.bo[bufnr].filetype] then
          lsp_format_opt = 'never'
        else
          lsp_format_opt = 'fallback'
        end
        return {
          timeout_ms = 5000,
          lsp_format = lsp_format_opt,
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        -- Don't set formatter for F# so that the fsautocomplete formatting will be used, which respects project specific fantomas versions and settings
        -- fsharp = { 'fantomas' },
        json = { 'prettier' },
        markdown = { 'prettier' },
        -- Use the "_" filetype to run formatters on filetypes that don't
        -- have other formatters configured.
        ['_'] = { 'trim_whitespace' },

        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- You can use 'stop_after_first' to run the first available formatter from the list
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
      },
    },
  },

  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'gbprod/nord.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      require('nord').setup {
        transparent = true,
        on_highlights = function(highlights, colors)
          -- The default highlighting for diffs overrides the foreground syntax
          -- highlighting. This changes it to an approach more like tokyo-night
          -- which marks the diff regions using only the background colors
          highlights.DiffAdd = { bg = colors.polar_night.brightest }
          -- Deleted text is just the deletion markers and not any content, so
          -- we set the foreground
          highlights.DiffDelete = { fg = colors.aurora.red }
          -- DiffText sits on top of DiffChange, so it should stand out
          highlights.DiffChange = { bg = colors.polar_night.bright }
          highlights.DiffText = { bg = colors.polar_night.brightest }
          highlights.FloatBorder = { fg = colors.frost.artic_ocean }
        end,
      }
      vim.cmd.colorscheme 'nord'
    end,
  },

  {
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('tokyonight').setup {
        transparent = true,
      }
      -- vim.cmd.colorscheme 'tokyonight-storm'
    end,
  },

  {
    'rebelot/kanagawa.nvim',
    priority = 1000,
    config = function()
      require('kanagawa').setup {
        compile = false, -- enable compiling the colorscheme
        undercurl = true, -- enable undercurls
        commentStyle = {},
        functionStyle = {},
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
        typeStyle = {},
        transparent = false, -- do not set background color
        dimInactive = false, -- dim inactive window `:h hl-NormalNC`
        terminalColors = true, -- define vim.g.terminal_color_{0,17}
        colors = { -- add/modify theme and palette colors
          palette = {},
          theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
        },
        overrides = function(colors) -- add/modify highlights
          return {}
        end,
        theme = 'wave', -- Load "wave" theme when 'background' option is not set
        background = { -- map the value of 'background' option to a theme
          dark = 'wave', -- try "dragon" !
          light = 'lotus',
        },
      }
      -- vim.cmd.colorscheme 'kanagawa'
    end,
  },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'ghostbuster91/nvim-next',
    },
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    opts = function()
      local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
      ---@diagnostic disable-next-line: param-type-mismatch
      -- parser_config.fsharp.install_info.url = 'https://github.com/rynoV/tree-sitter-fsharp'
      parser_config.fsharp.install_info.url = vim.fs.joinpath(vim.fn.stdpath 'config', 'tree-sitter-fsharp')

      require('nvim-next.integrations').treesitter_textobjects()
      return {
        ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
        -- Autoinstall languages that are not installed
        auto_install = true,
        highlight = {
          enable = true,
          -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
          --  If you are experiencing weird indenting issues, add the language to
          --  the list of additional_vim_regex_highlighting and disabled languages for indent.
          additional_vim_regex_highlighting = { 'ruby' },
        },
        indent = {
          enable = true,
          disable = {
            'ruby',
            -- F# treesitter indentation is hard, instead I've copied the vim format script from the ionide plugin
            'fsharp',
          },
        },
        textobjects = {
          select = {
            enable = true,

            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,

            keymaps = {
              ['af'] = { query = '@function.outer', desc = 'Around function' },
              ['if'] = { query = '@function.inner', desc = 'Inside function' },
            },
            selection_modes = {
              ['@function.outer'] = 'V', -- linewise
            },
            include_surrounding_whitespace = false,
          },
          lsp_interop = {
            enable = true,
            border = 'none',
            floating_preview_opts = {},
            peek_definition_code = {
              ['<leader>df'] = '@function.outer',
            },
          },
        },
        nvim_next = {
          enable = true,
          textobjects = {
            move = {
              goto_next_start = {
                [']f'] = { query = '@function.outer', desc = 'Next function start' },
              },
              goto_next_end = {
                [']F'] = { query = '@function.outer', desc = 'Next function end' },
              },
              goto_previous_start = {
                ['[f'] = { query = '@function.outer', desc = 'Previous function start' },
              },
              goto_previous_end = {
                ['[F'] = { query = '@function.outer', desc = 'Previous function end' },
              },
              -- Below will go to either the start or the end, whichever is closer.
              -- Use if you want more granular movements
              -- Make it even more gradual by adding multiple queries and regex.
              goto_next = {},
              goto_previous = {},
            },
          },
        },
      }
    end,
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    opts = {
      enable = true,
    },
    config = function()
      vim.keymap.set('n', '<leader>tx', '<cmd>TSContextToggle<cr>', { desc = 'Toggle code context' })
    end,
  },
  {
    'RRethy/nvim-treesitter-textsubjects',
    config = function()
      require('nvim-treesitter-textsubjects').configure {}
    end,
  },

  -- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',
  -- require 'kickstart.plugins.lint',
  require 'kickstart.plugins.autopairs',
  -- require 'kickstart.plugins.neo-tree',
  require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  { import = 'custom.plugins' },
  --
  -- For additional information with loading, sourcing and examples see `:help lazy.nvim-🔌-plugin-spec`
  -- Or use telescope!
  -- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
  -- you can continue same window with `<space>sr` which resumes last telescope search
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- For some reason these only work when placing them after the plugin spec
local next_integrations = require 'nvim-next.integrations'
local nndiag = next_integrations.diagnostic()
local nqf = next_integrations.quickfix()

local move = require 'nvim-next.move'
-- These are relative to the cursor, and don't work in the loc window
local prev_loc_item_relative, next_loc_item_relative = move.make_repeatable_pair(function(_)
  local status, _ = pcall(vim.cmd['lbefore'])
  if not status then
    vim.notify('No more items', vim.log.levels.INFO, { title = 'LocList' })
  end
end, function(_)
  local status, _ = pcall(vim.cmd['lafter'])
  if not status then
    vim.notify('No more items', vim.log.levels.INFO, { title = 'LocList' })
  end
end)

-- These are based on the current position in the loc list, and do work in the loc window
local prev_loc_item_absolute, next_loc_item_absolute = move.make_repeatable_pair(function(_)
  local status, _ = pcall(vim.cmd['lprevious'])
  if not status then
    vim.notify('No more items', vim.log.levels.INFO, { title = 'LocList' })
  end
end, function(_)
  local status, _ = pcall(vim.cmd['lnext'])
  if not status then
    vim.notify('No more items', vim.log.levels.INFO, { title = 'LocList' })
  end
end)

vim.keymap.set('n', '[q', nqf.cprevious, { desc = 'previous quickfix list item' })
vim.keymap.set('n', ']q', nqf.cnext, { desc = 'next quickfix list item' })
vim.keymap.set('n', '[l', prev_loc_item_relative, { desc = 'previous location list item relative to cursor' })
vim.keymap.set('n', ']l', next_loc_item_relative, { desc = 'next location list item relative to cursor' })
vim.keymap.set('n', '[L', prev_loc_item_absolute, { desc = 'previous location list item' })
vim.keymap.set('n', ']L', next_loc_item_absolute, { desc = 'next location list item' })
vim.keymap.set('n', '[d', nndiag.goto_prev { severity = { min = vim.diagnostic.severity.WARN } }, { desc = 'previous diagnostic' })
vim.keymap.set('n', ']d', nndiag.goto_next { severity = { min = vim.diagnostic.severity.WARN } }, { desc = 'next diagnostic' })

local util = require 'custom.util'

vim.keymap.set('n', '[c', util.prev_change, { desc = 'previous change' })
vim.keymap.set('n', ']c', util.next_change, { desc = 'next change' })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
