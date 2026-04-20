---@type LazySpec
return {
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
  {
    'aaronik/treewalker.nvim',

    -- The following options are the defaults.
    -- Treewalker aims for sane defaults, so these are each individually optional,
    -- and setup() does not need to be called, so the whole opts block is optional as well.
    opts = {
      -- Whether to briefly highlight the node after jumping to it
      highlight = true,

      -- How long should above highlight last (in ms)
      highlight_duration = 250,

      -- The color of the above highlight. Must be a valid vim highlight group.
      -- (see :h highlight-group for options)
      highlight_group = 'CursorLine',
    },

    keys = {
      { '<C-k>', '<cmd>Treewalker Up<cr>', silent = true, mode = { 'n', 'v' } },
      { '<C-j>', '<cmd>Treewalker Down<cr>', silent = true, mode = { 'n', 'v' } },
      { '<C-h>', '<cmd>Treewalker Left<cr>', silent = true, mode = { 'n', 'v' } },
      { '<C-l>', '<cmd>Treewalker Right<cr>', silent = true, mode = { 'n', 'v' } },
      { '<C-A-k>', '<cmd>Treewalker SwapUp<cr>', silent = true },
      { '<C-A-j>', '<cmd>Treewalker SwapDown<cr>', silent = true },
      { '<C-A-h>', '<cmd>Treewalker SwapLeft<cr>', silent = true },
      { '<C-A-l>', '<cmd>Treewalker SwapRight<cr>', silent = true },
    },
  },
}
