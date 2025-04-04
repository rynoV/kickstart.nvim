return {
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim', -- required
      'sindrets/diffview.nvim', -- optional - Diff integration

      -- Only one of these is needed.
      -- 'ibhagwan/fzf-lua', -- optional
      -- 'echasnovski/mini.pick', -- optional
    },
    cmd = 'Neogit',
    keys = {
      { '<leader>mgg', '<cmd>Neogit<cr>', desc = 'Neogit', mode = 'n' },
    },
    opts = function(_, opts)
      opts.integrations = { diffview = true }
      opts.disable_hint = true
      return opts
    end,
  },
  {
    'sindrets/diffview.nvim',
    opts = function()
      local next_move = require 'nvim-next.move'
      local actions = require 'diffview.actions'
      local prev_conflict, next_conflict = next_move.make_repeatable_pair(actions.prev_conflict, actions.next_conflict)
      return {
        keymaps = {
          view = {
            { 'n', '[x', prev_conflict, { desc = 'In the merge-tool: jump to the previous conflict' } },
            { 'n', ']x', next_conflict, { desc = 'In the merge-tool: jump to the next conflict' } },
          },
          file_panel = {
            { 'n', '[x', prev_conflict, { desc = 'Go to the previous conflict' } },
            { 'n', ']x', next_conflict, { desc = 'Go to the next conflict' } },
          },
        },
      }
    end,
  },
}
