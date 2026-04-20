---@type LazySpec
return {
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
}
