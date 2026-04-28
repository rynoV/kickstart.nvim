---@type LazySpec
local conform = {
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
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end
      return {
        lsp_format = 'fallback',
        timeout_ms = 5000,
      }
    end,
    formatters = {
      hledger_fmt = {
        command = 'hledger-fmt',
        args = { '--no-diff', '-' },
      },
      -- This is included in recent versions of conform, so it can be removed
      -- when we unlock the version
      tombi = {
        meta = {
          url = 'https://github.com/tombi-toml/tombi',
          description = 'TOML Formatter / Linter.',
        },
        command = 'tombi',
        args = { 'format', '--stdin-filename', '$FILENAME', '-' },
        stdin = true,
      },
    },
    formatters_by_ft = {
      lua = { 'stylua' },
      -- Ensure F# uses  the fsautocomplete formatting, which respects project
      -- specific fantomas versions and settings. Unfortunately just having lsp
      -- as the fallback doesn't seem to work when the '_' key is set
      -- https://github.com/stevearc/conform.nvim/issues/846
      fsharp = { lsp_format = 'prefer' },
      typescript = { 'prettier' },
      typescriptreact = { 'prettier' },
      javascript = { 'prettier' },
      javascriptreact = { 'prettier' },
      json = { 'prettier' },
      markdown = { 'prettier' },
      ledger = { 'hledger_fmt' },
      toml = { 'tombi' },
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
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
        -- Global autoformat toggle
        Snacks.toggle
          .new({
            name = 'Format on save',
            get = function()
              return not vim.g.disable_autoformat
            end,
            set = function(v)
              vim.g.disable_autoformat = not v
            end,
          })
          :map '<leader>to'

        -- Buffer-local autoformat toggle
        Snacks.toggle
          .new({
            name = 'Format on save (buffer)',
            get = function()
              return not vim.b.disable_autoformat
            end,
            set = function(v)
              vim.b.disable_autoformat = not v
            end,
          })
          :map '<leader>tO'
      end,
    })
  end,
}

return {
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  conform,
}
