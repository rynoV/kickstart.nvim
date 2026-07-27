return {
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
      -- I couldn't figure out a good way to call the original root_dir
      -- implementation, but this is the same as the lspconfig implementation
      -- as of
      -- https://github.com/neovim/nvim-lspconfig/blob/d224a1920728ba129880efc700d4a0180ac4ecbb/lsp/fsautocomplete.lua
      on_dir(require('lspconfig.util').root_pattern('*.sln', '*.slnx', '*.fsproj', '.git')(buf_path))
    end
  end,
}
