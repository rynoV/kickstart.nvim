local find_rust_bin = function()
  return vim.fn.expand '~' .. '/code/surrealql-lsp/target/debug/surrealql-lsp-server'
end

---@type vim.lsp.Config
return {
  cmd = { find_rust_bin() },
  filetypes = { 'surql' },
  root_dir = function(_, cb)
    cb(vim.fn.getcwd())
  end,
}
