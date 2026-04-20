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
    -- A little more readable than the default "NonText" link
    vim.api.nvim_set_hl(0, 'SnacksDebugPrint', { link = 'Comment' })
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
