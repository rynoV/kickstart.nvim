local is_macos = vim.fn.has 'mac' == 1
return {
  'GustavEikaas/easy-dotnet.nvim',
  enabled = not is_macos,
  dependencies = { 'nvim-lua/plenary.nvim', 'folke/snacks.nvim' },
  config = function()
    require('easy-dotnet').setup()
    -- Abbreviation for :Dotnet user command. Note this will expand anywhere in
    -- the command line after pressing space
    vim.cmd 'cnoreabbrev dn Dotnet'
  end,
}
