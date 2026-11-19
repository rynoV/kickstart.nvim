This is my personal neovim configuration.

- `init.lua` is the main entry point and contains all kinds of code
- Some plugin configuration is contained in `lua/*`
- Some filetype configuration is in `after/ftplugin/*`
- Some custom LSP configuration is in `lsp/*`
- Some custom treesitter queries are in `queries/*`
- To update parsers, use the standard nvim-treesitter mechanisms within neovim
  (`:TSUpdate`, `:TSInstall!`). The tree-sitter CLI is managed by mason and is
  available inside neovim, so don't compile parsers manually with gcc.

You have a Lua language server configured for this project available to you to
help complete your tasks.
