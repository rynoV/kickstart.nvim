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
  {
    'esmuellert/codediff.nvim',
    dependencies = { 'MunifTanjim/nui.nvim' },
    cmd = 'CodeDiff',
    opts = {
      -- NOTE: if the colorscheme's DiffAdd color is too light, for some reason
      -- the text foreground gets locked to black hide syntax highlighting
      -- highlights = {
      --   line_insert = '#3B4252',
      -- },
    },
  },
  {
    -- Pending https://github.com/georgeguimaraes/review.nvim/pull/13
    -- 'georgeguimaraes/review.nvim',
    'rynoV/review.nvim',
    dependencies = {
      'esmuellert/codediff.nvim',
      'MunifTanjim/nui.nvim',
    },
    cmd = { 'Review' },
    keys = {
      { '<leader>ar', '<cmd>Review<cr>', desc = 'Review' },
    },
    opts = {
      codediff = {
        readonly = false,
      },
      keymaps = {
        add_note = '<leader>cn',
        add_suggestion = '<leader>cs',
        add_issue = '<leader>ci',
        add_praise = '<leader>cp',
        delete_comment = '<leader>cd',
        edit_comment = '<leader>ce',
        next_comment = ']n',
        prev_comment = '[n',
        list_comments = '<leader>cl',
        comments_to_clipboard = '<leader>cy',
        comments_to_sidekick = '<leader>cS',
        clear_comments = '<leader>cccc',
        close = '<leader>cq',
        toggle_readonly = '<leader>cR',
      },
    },
  },
}
