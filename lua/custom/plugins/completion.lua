return {
  'saghen/blink.cmp',
  dependencies = {
    'zbirenbaum/copilot.lua',
    {
      'L3MON4D3/LuaSnip',
      build = (function()
        -- Build Step is needed for regex support in snippets.
        -- This step is not supported in many windows environments.
        -- Remove the below condition to re-enable on windows.
        if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
          return
        end
        return 'make install_jsregexp'
      end)(),
      config = function()
        local luasnip = require 'luasnip'
        luasnip.config.setup {}
        require('luasnip.loaders.from_lua').load { paths = { vim.fn.stdpath 'config' .. '/snippets' } }
      end,
      keys = {
        {
          '<leader>mse',
          function()
            require('luasnip.loaders').edit_snippet_files()
          end,
          desc = '[E]dit snippets',
        },
        -- Note blink.cmp configures tab and shift-tab for this
        {
          '<C-l>',
          function()
            local luasnip = require 'luasnip'

            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end,
          desc = 'Expand or jump in snippet',
          mode = { 'i', 's' },
        },
        {
          '<C-h>',
          function()
            local luasnip = require 'luasnip'

            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end,
          desc = 'Jump back in snippet',
          mode = { 'i', 's' },
        },
      },
    },
  },

  -- use a release tag to download pre-built binaries
  version = '1.*',
  -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
  -- build = 'cargo build --release',

  opts = function()
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    local opts = {
      signature = { enabled = true },
      snippets = { preset = 'luasnip' },
      -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
      -- 'super-tab' for mappings similar to vscode (tab to accept)
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- All presets have the following mappings:
      -- C-space: Open menu or open docs if already open
      -- C-n/C-p or Up/Down: Select next/previous item
      -- C-e: Hide menu
      -- C-k: Toggle signature help (if signature.enabled = true)
      --
      -- See :h blink-cmp-config-keymap for defining your own keymap
      keymap = {
        preset = 'enter',
        ['<C-space>'] = { 'show_documentation', 'hide_documentation' },
        ['<C-n>'] = { 'show', 'select_next', 'fallback_to_mappings' },
        ['<Tab>'] = {
          function()
            local copilot = require 'copilot.suggestion'
            if copilot.is_visible() then
              copilot.accept()
              return true
            else
              return false
            end
          end,
          'snippet_forward',
          'fallback',
        },
        ['<A-1>'] = {
          function(cmp)
            cmp.accept { index = 1 }
          end,
        },
        ['<A-2>'] = {
          function(cmp)
            cmp.accept { index = 2 }
          end,
        },
        ['<A-3>'] = {
          function(cmp)
            cmp.accept { index = 3 }
          end,
        },
        ['<A-4>'] = {
          function(cmp)
            cmp.accept { index = 4 }
          end,
        },
        ['<A-5>'] = {
          function(cmp)
            cmp.accept { index = 5 }
          end,
        },
        ['<A-6>'] = {
          function(cmp)
            cmp.accept { index = 6 }
          end,
        },
        ['<A-7>'] = {
          function(cmp)
            cmp.accept { index = 7 }
          end,
        },
        ['<A-8>'] = {
          function(cmp)
            cmp.accept { index = 8 }
          end,
        },
        ['<A-9>'] = {
          function(cmp)
            cmp.accept { index = 9 }
          end,
        },
        ['<A-0>'] = {
          function(cmp)
            cmp.accept { index = 10 }
          end,
        },
      },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'normal',
      },

      completion = {
        documentation = { auto_show = false },
        menu = {
          auto_show = false,
          max_height = 12, -- For some reason this seems needed for it to show ten items, else it shows 8
          -- https://cmp.saghen.dev/recipes#select-nth-item-from-the-list
          draw = {
            columns = { { 'item_idx' }, { 'kind_icon' }, { 'label', 'label_description', gap = 1 } },
            components = {
              item_idx = {
                text = function(ctx)
                  return ctx.idx == 10 and '0' or ctx.idx >= 10 and ' ' or tostring(ctx.idx)
                end,
                highlight = 'BlinkCmpItemIdx', -- optional, only if you want to change its color
              },
            },
          },
        },
        ghost_text = { enabled = false },
        keyword = { range = 'full' },
      },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { 'lsp', 'easy-dotnet', 'path', 'snippets', 'buffer' },
        providers = {
          ['easy-dotnet'] = {
            name = 'easy-dotnet',
            enabled = true,
            module = 'easy-dotnet.completion.blink',
            score_offset = 10000,
            async = true,
          },
        },
      },

      -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
      -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
      -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
      --
      -- See the fuzzy documentation for more information
      fuzzy = { implementation = 'prefer_rust_with_warning' },
    }
    return opts
  end,
  opts_extend = { 'sources.default' },
}
