local is_macos = vim.fn.has 'mac' == 1
--- @type LazyPluginSpec
return {
  'GustavEikaas/easy-dotnet.nvim',
  cond = not is_macos,
  -- This plugin in fairly slow to load, and using ft technically adds to
  -- startup time, but it is at the very end of the load sequence so it is not
  -- noticeable, and using filetype based lazy loading instead of VeryLazy
  -- avoids loading this when it is not needed.
  ft = { 'fsharp', 'fsharp_project', 'csharp', 'csharp_project' },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'folke/snacks.nvim',
    {
      'saghen/blink.cmp',
      opts = {
        sources = {
          default = { 'easy-dotnet' },
        },
      },
    },
  },
  config = function()
    require('easy-dotnet').setup {
      lsp = {
        auto_refresh_codelens = false,
        enabled = false,
      },
    }
    -- Abbreviation for :Dotnet user command. Note this will expand anywhere in
    -- the command line after pressing space
    vim.cmd 'cnoreabbrev dn Dotnet'
  end,
}
