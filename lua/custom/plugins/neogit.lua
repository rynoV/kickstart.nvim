return {
  'NeogitOrg/neogit',
  dependencies = {
    'nvim-lua/plenary.nvim', -- required
    'sindrets/diffview.nvim', -- optional - Diff integration

    -- Only one of these is needed.
    'nvim-telescope/telescope.nvim', -- optional
    -- 'ibhagwan/fzf-lua', -- optional
    -- 'echasnovski/mini.pick', -- optional
  },
  cmd = 'Neogit',
  opts = function(_, opts)
    opts.integrations = { telescope = true, diffview = true }
    opts.disable_hint = true
    return opts
  end,
}
