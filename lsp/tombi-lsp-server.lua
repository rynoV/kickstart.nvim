--- https://github.com/tombi-toml/tombi
--- Mainly for Cargo.toml
---@type vim.lsp.Config
return {
  cmd = { 'tombi', 'lsp' },
  filetypes = { 'toml' },
  root_markers = { 'tombi.toml', '.git' },
}
