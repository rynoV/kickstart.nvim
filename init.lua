if require('flatten').setup() then
  return
end

if vim.loader then
  -- Seems to take about 10ms off startup at time of writing
  vim.loader.enable()
end

require('vim._core.ui2').enable()

-- Setup some globals for debugging (lazy-loaded)
_G.dd = function(...)
  Snacks.debug.inspect(...)
end
_G.bt = function()
  Snacks.debug.backtrace()
end
-- Override print to use snacks for `:=` command
---@diagnostic disable-next-line: duplicate-set-field
vim._print = function(_, ...)
  dd(...)
end

if vim.env.PROF then
  -- Assumes lazy.nvim
  local snacks = vim.fn.stdpath 'data' .. '/lazy/snacks.nvim'
  vim.opt.rtp:append(snacks)
  require('snacks.profiler').startup {
    startup = {
      event = 'VimEnter', -- stop profiler on this event. Defaults to `VimEnter`
      -- event = "UIEnter",
      -- event = "VeryLazy",
    },
  }
end

require 'config.options'

vim.api.nvim_create_autocmd('User', {
  pattern = 'VeryLazy',
  callback = function()
    require 'config.keymaps'
    require 'config.autocmds'
  end,
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

require('lazy').setup({
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    dependencies = {
      {
        'saghen/blink.cmp',
        opts = {
          sources = {
            default = { 'lazydev' },
          },
        },
      },
    },
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        { path = 'snacks.nvim', words = { 'Snacks' } },
        { path = 'lazy.nvim', words = { 'LazyPluginSpec' } },
      },
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    event = 'VeryLazy',
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
            if vim.wo[win][0].foldmethod ~= 'diff' then
              -- Note: treesitter configuration may also set the foldexpr, but
              -- that should happen before the lsp attaches, so this should
              -- override it
              vim.wo[win][0].foldmethod = 'expr'
              vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
            end
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
        -- lazydev handles some configuration for lua_ls but doesn't install or
        -- enable it. The rest of this config is copied from LazyVim:
        -- https://github.com/LazyVim/LazyVim/blob/83d90f339defdb109a6ede333865a66ffc7ef6aa/lua/lazyvim/plugins/lsp/init.lua#L123
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              codeLens = {
                enable = true,
              },
              completion = {
                callSnippet = 'Replace',
              },
              doc = {
                privateName = { '^_' },
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = 'Disable',
                semicolon = 'Disable',
                arrayIndex = 'Disable',
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
  { 'folke/todo-comments.nvim', event = 'VeryLazy', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

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
        'xml',
        'fsharp',
        'fsharp_project',
        'c_sharp',
      }

      -- Languages that rely on old regex syntax highlighting even though they
      -- have treesitter
      local legacy_syntax = {
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
      }

      local no_ts_highlight = {
        -- Treesitter syntax highlighting is inconsistent for fsharp
        'fsharp',
      }

      vim.treesitter.language.register('xml', { 'fsharp_project' })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = { '*' },
        callback = function(args)
          local ft = vim.bo[args.buf].filetype
          local lang = vim.treesitter.language.get_lang(ft)

          if not lang then
            return
          end

          if
            not vim.treesitter.language.add(lang)
            and vim.tbl_contains(auto_filetypes, ft)
            and vim.tbl_contains(require('nvim-treesitter').get_available(), lang)
          then
            require('nvim-treesitter').install(lang):wait(30000) -- wait max 5 minutes
          end

          if vim.treesitter.language.add(lang) and vim.tbl_contains(auto_filetypes, ft) then
            if not vim.tbl_contains(no_ts_highlight, ft) then
              vim.treesitter.start(args.buf, lang)
            end
            if vim.tbl_contains(legacy_syntax, ft) then
              vim.bo[args.buf].syntax = 'ON'
            end

            local win = vim.api.nvim_get_current_win()
            if vim.wo[win][0].foldmethod ~= 'diff' then
              vim.wo[win][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
              vim.wo[win][0].foldmethod = 'expr'
            end

            -- this is an experimental feature
            -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = 'VeryLazy',
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
  performance = {
    -- This allows using vim.cmd.packadd to enable optional built-in plugins.
    -- It seems to add a few milliseconds to startup in some cases but not
    -- significant
    rtp = { reset = false },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
