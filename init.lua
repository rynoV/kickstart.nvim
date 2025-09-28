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

vim.g.health = { style = 'float' }

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
-- Use syntax highlighting for showing the first line of a closed fold
-- https://github.com/neovim/neovim/pull/20750
vim.opt.foldtext = ''
vim.opt.fillchars = 'fold: '

-- Show a border for floating windows
vim.opt.winborder = 'rounded'

-- Behaviour I'm used to when closing tabs
vim.opt.tabclose = { 'uselast', 'left' }

vim.opt.completeopt:append { 'noinsert', 'popup' }

vim.opt.conceallevel = 2

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

vim.keymap.set('x', 'iL', '^o$h', { desc = 'Line content' })
vim.keymap.set('o', 'iL', ':normal viL<CR>', { desc = 'Line content' })

-- Hold over from emacs muscle memory
vim.keymap.set('c', '<C-g>', '<Esc>')

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

-- From :help terminal-scrollback-pager
function TermHl()
  local b = vim.api.nvim_create_buf(false, true)
  local chan = vim.api.nvim_open_term(b, {})
  vim.api.nvim_chan_send(chan, table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n'))
  vim.api.nvim_win_set_buf(0, b)
end

vim.api.nvim_create_user_command('TermHl', TermHl, { desc = 'Highlights ANSI termcodes in curbuf' })

vim.keymap.set('n', '<leader>mC', TermHl, { desc = 'Highlight ANSI termcodes in curbuf' })

-- From :help :DiffOrig
local function diff_orig()
  vim.cmd 'vert new | set buftype=nofile | read ++edit # | 0d_ | diffthis | wincmd p | diffthis'
end

vim.api.nvim_create_user_command('DiffOrig', diff_orig, {
  desc = 'Diff with the original file',
})

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
      preset = 'modern',
      -- delay between pressing a key and opening which-key (milliseconds)
      -- this setting is independent of vim.opt.timeoutlen
      delay = 50,
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
        { '<leader>u', group = 'ui' },
        { '<leader>g', group = 'git' },
      },
    },
    keys = {
      {
        '<leader>?',
        function()
          require('which-key').show { global = false }
        end,
        desc = 'Buffer Local Keymaps (which-key)',
      },
    },
  },

  -- NOTE: Plugins can specify dependencies.
  --
  -- The dependencies are proper plugin specifications as well - anything
  -- you do for a plugin at the top level, you can do for a dependency.
  --
  -- Use the `dependencies` key to specify the dependencies of a particular plugin

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
            override_vim_notify = false,
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

          local client = vim.lsp.get_client_by_id(event.data.client_id)

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
        servers.csharp_ls = {}
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

      -- Servers configured manually in the `lsp` folder
      vim.lsp.enable 'surrealql-lsp-server'
    end,
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
    init = function()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        callback = function()
          local m = require 'treesitter-context'
          Snacks.toggle
            .new({
              name = 'Code context',
              get = function()
                return m.enabled()
              end,
              set = function(v)
                if v then
                  m.enable()
                else
                  m.disable()
                end
              end,
            })
            :map '<leader>tx'
        end,
      })
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
  require 'kickstart.plugins.lint',
  require 'kickstart.plugins.autopairs',
  -- require 'kickstart.plugins.neo-tree',
  require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  { import = 'custom.plugins' },
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

local util = require 'custom.util'

vim.keymap.set('n', '[c', util.prev_change, { desc = 'previous change' })
vim.keymap.set('n', ']c', util.next_change, { desc = 'next change' })
vim.keymap.set('n', '<leader>mf', util.open_file_in_last_tab, { desc = 'Open file at cursor in previously accessed tab page' })

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

vim.diagnostic.config { virtual_lines = false }

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

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
