--- Used for FSI integration. <M-CR> to send code to FSI and <M-@> to toggle the FSI terminal window
---@type LazySpec
return {
  {
    'ionide/Ionide-vim',
    ft = { 'fsharp', 'fsharp_project' },
    -- Set the variables in `init` because (1) some of the ionide plugin's
    -- setup expects them to be defined before it loads, and (2) so they can be
    -- overridden in project-local config files
    init = function()
      -- Setup fsautocomplete through lspconfig, it's good enough
      vim.g['fsharp#backend'] = 'disable'
      -- Show fsi in horizontal split
      vim.g['fsharp#fsi_window_command'] = 'vnew'
      -- Recommended: Paket files are excluded from the project loader.
      vim.g['fsharp#exclude_project_directories'] = { 'paket-files' }
      vim.g['fsharp#fsi_extra_shared_parameters'] = { '--langversion:preview' }
    end,
  },
}
