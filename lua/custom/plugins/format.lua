return {
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
    { '<leader>to', '<cmd>FormatToggle<cr>', desc = 'Toggle autoformat' },
    { '<leader>tO', '<cmd>FormatToggle!<cr>', desc = 'Toggle autoformat for buffer' },
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
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    vim.api.nvim_create_user_command('FormatToggle', function(args)
      if args.bang then
        vim.b.disable_autoformat = not vim.b.disable_autoformat
        local status = vim.b.disable_autoformat and 'disabled' or 'enabled'
        vim.notify('Buffer auto formatting ' .. status)
      else
        vim.g.disable_autoformat = not vim.g.disable_autoformat
        local status = vim.g.disable_autoformat and 'disabled' or 'enabled'
        vim.notify('Global auto formatting ' .. status)
      end
    end, {
      desc = 'Toggle autoformat-on-save',
      bang = true,
    })
  end,
}
