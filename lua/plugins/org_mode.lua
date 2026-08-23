---@LazyPluginSpec
return {
  'nvim-orgmode/orgmode',
  event = 'VeryLazy',
  ft = { 'org' },
  config = function()
    -- Setup orgmode
    require('orgmode').setup {
      org_agenda_files = '~/orgfiles/**/*',
      org_default_notes_file = '~/orgfiles/refile.org',
      org_adapt_indentation = false,
      ui = {
        input = {
          use_vim_ui = true,
        },
        folds = {
          -- Coloring folds causes a lot of lag for large files
          colored = false,
        },
      },
    }

    -- Experimental LSP support
    -- vim.lsp.enable 'org'
  end,
}
