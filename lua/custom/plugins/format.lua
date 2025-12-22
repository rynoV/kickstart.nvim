return {
  'stevearc/conform.nvim',
  -- Locked here until this is fixed: https://github.com/stevearc/conform.nvim/issues/752
  commit = 'f9ef25a7ef00267b7d13bfc00b0dea22d78702d5',
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
      -- Don't set formatter for F# so that the fsautocomplete formatting will be used, which respects project specific fantomas versions and settings
      -- fsharp = { 'fantomas' },
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
