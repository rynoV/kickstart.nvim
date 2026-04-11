require('vim._core.ui2').enable()

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

-- Ignore leading '-' for numbers when using C-a or C-x
vim.opt.nrformats:append { 'unsigned' }

vim.opt.conceallevel = 2

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

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
  callback = function()
    vim.opt_local.relativenumber = true
    vim.opt_local.scrollback = 100000
  end,
})

-- From :help terminal-scrollback-pager
function TermHl()
  vim.api.nvim_open_term(0, {})
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

vim.lsp.codelens.enable()
vim.lsp.on_type_formatting.enable()

-- Lint treesitter queries :help ft-query-plugin
vim.g.query_lint_on = { 'InsertLeave', 'TextChanged' }

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
      -- This handles mapping language server names to mason tool names, so
      -- that mason-tool-installer is easier to use to handle lsp server
      -- installation
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
      local custom_util = require 'custom.util'

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- FSAutocomplete can currently freeze neovim when semantic tokens are enabled
          -- https://github.com/neovim/neovim/issues/36257
          if client and (client.name == 'fsautocomplete' or client.name == 'ionide') and client.server_capabilities then
            client.server_capabilities.semanticTokensProvider = nil
          end

          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_foldingRange) then
            local win = vim.api.nvim_get_current_win()
            -- Note: treesitter configuration may also set the foldexpr, but
            -- that should happen before the lsp attaches, so this should
            -- override it
            vim.wo[win][0].foldmethod = 'expr'
            vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
          end

          -- Helps for example in html/jsx/tsx to edit the closing and ending
          -- tag simultaneously by just changing one
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_linkedEditingRange) then
            vim.lsp.linked_editing_range.enable()
          end
        end,
      })

      local servers = {
        ts_ls = {},
        eslint = {},
        copilot = {},
        -- Special Lua Config, as recommended by neovim help docs
        lua_ls = {
          on_init = function(client)
            if client.workspace_folders then
              local path = client.workspace_folders[1].name
              if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then
                return
              end
            end

            client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
              runtime = {
                version = 'LuaJIT',
                path = { 'lua/?.lua', 'lua/?/init.lua' },
              },
              workspace = {
                checkThirdParty = false,
                library = {
                  vim.env.VIMRUNTIME,
                },
              },
            })
          end,
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
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

      local ensure_installed = vim.tbl_filter(function(v)
        -- We don't want rust_analyzer to be automatically installed
        return v ~= 'rust_analyzer'
      end, vim.tbl_keys(servers or {}))
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
        -- 'prettier',
      })

      if is_windows then
        vim.list_extend(ensure_installed, {
          -- 'fantomas', -- F# formatting
        })
      end

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      -- Servers configured manually in the `lsp` folder
      servers.surrealql_lsp_server = {}
      servers.tombi_lsp_server = {}
      servers.actionsls = {}

      -- Allow using neovim for quickly viewing diffs without lsp
      for name, server in pairs(servers) do
        vim.lsp.config(name, server)
        if not custom_util.started_with_diff_args then
          vim.lsp.enable(name)
        end
      end
    end,
  },
  {
    'gbprod/nord.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      require('nord').setup {
        transparent = true,
        on_highlights = function(highlights, colors)
          -- The default highlighting for diffs overrides the foreground syntax
          -- highlighting. This changes it to an approach more like tokyo-night
          -- which marks the diff regions using only the background colors
          highlights.DiffAdd = { bg = colors.polar_night.bright }
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

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    -- Note on first install this won't use parser customizations (like custom
    -- forks or local versions), and it will be necessary to run :TSUpdate
    -- again
    build = ':TSUpdate',
    config = function()
      -- This gets run by nvim-treesitter in various functions before it loads
      -- configuration, so that we can modify configuration here
      vim.api.nvim_create_autocmd('User', {
        pattern = 'TSUpdate',
        callback = function()
          require('nvim-treesitter.parsers').fsharp.install_info.path = vim.fs.joinpath(vim.fn.stdpath 'config', 'tree-sitter-fsharp')
        end,
      })

      -- Setup some languages automatically. Some languages have parsers
      -- included with the neovim installation, and some languages' parsers
      -- will be managed by nvim-treesitter. `:che vim.treesitter` will show
      -- the installed parsers and their locations
      local auto_filetypes = {
        'bash',
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
        'fsharp',
      }

      -- Languages that rely on old regex syntax highlighting even though they
      -- have treesitter
      local legacy_syntax = {
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
      }

      vim.api.nvim_create_autocmd('FileType', {
        pattern = { '*' },
        callback = function(args)
          local ft = vim.bo[args.buf].filetype
          local lang = vim.treesitter.language.get_lang(ft)

          if
            not vim.treesitter.language.add(lang)
            and vim.tbl_contains(auto_filetypes, lang)
            and vim.tbl_contains(require('nvim-treesitter').get_available(), lang)
          then
            require('nvim-treesitter').install(lang):wait(30000) -- wait max 5 minutes
          end

          if vim.treesitter.language.add(lang) and vim.tbl_contains(auto_filetypes, lang) then
            vim.treesitter.start(args.buf, lang)
            if vim.tbl_contains(legacy_syntax, lang) then
              vim.bo[args.buf].syntax = 'ON'
            end
            -- this is an experimental feature
            -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
            vim.wo[0][0].foldmethod = 'expr'
          end
        end,
      })
    end,
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

  require 'kickstart.plugins.lint',
  require 'kickstart.plugins.autopairs',
  require 'kickstart.plugins.gitsigns',

  -- NOTE: Automatically add plugins, configuration, etc from `lua/custom/plugins/*.lua`
  { import = 'custom.plugins' },
  { import = 'custom.vscode' },
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

vim.keymap.set('n', '<leader>mf', util.open_file_in_last_tab, { desc = 'Open file at cursor in previously accessed tab page' })

-- Override these actions with repeatable wrappers
util.make_repeatable_wrappers(require('custom.plugins.notes').haunt_prefix .. 'p', require('custom.plugins.notes').haunt_prefix .. 'n')
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

-- For some reason this packadd needs to come near the end of the file or it
-- doesn't load the plugin
vim.cmd 'packadd! nvim.undotree'
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

vim.opt.diffopt:remove 'inline:char'

vim.opt.diffopt:append {
  -- Using the new directory nvim.difftool with anchors breaks things if
  -- hiddenoff is not set
  'hiddenoff',
  'vertical',
  'inline:word',
  'anchor',
}

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

vim.cmd 'packadd! nvim.difftool'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
