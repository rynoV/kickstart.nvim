-- Comment settings
vim.opt_local.formatoptions = 'croqljn'
vim.opt_local.comments = 's0:*,m0:*,ex0:*),s1:(*,mb:*,ex:*),:///,://'
-- Useful if not handled by another plugin
-- folke/ts-comments.nvim sets this
-- vim.opt_local.commentstring = '// %s'

vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.wo.foldminlines = 1

-- Uses the settings from here: https://github.com/neovim/neovim/blob/master/runtime/compiler/dotnet.vim
vim.cmd 'compiler! dotnet'

vim.lsp.codelens.enable(false, { bufnr = 0 })

vim.lsp.config('fsautocomplete', {
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
  root_dir = function(bufnr, on_dir)
    -- Don't attach the lsp for temp files
    local custom_util = require 'calum.util'
    local buf_path = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))
    if not (custom_util.path_in_temp_dir(buf_path) or custom_util.git_difftool_path(buf_path) ~= nil) then
      on_dir(vim.fn.getcwd())
    end
  end,
})

vim.lsp.enable 'fsautocomplete'
