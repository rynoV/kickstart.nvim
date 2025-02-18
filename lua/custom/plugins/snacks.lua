return {
  'folke/snacks.nvim',
  ---@type snacks.Config
  opts = {
    bigfile = {},
    gitbrowse = {},
    quickfile = {}, -- When doing `nvim somefile.txt`, render the file as quickly as possible, before loading plugins
  },
  config = function()
    -- Delete buffer without affecting windows/tabs
    vim.keymap.set('n', '<leader>bd', require('snacks').bufdelete.delete, { desc = 'Delete buffer' })
    vim.keymap.set('n', '<leader>bO', require('snacks').bufdelete.other, { desc = 'Delete other buffers' })
    vim.keymap.set('n', '<leader>bA', require('snacks').bufdelete.all, { desc = 'Delete other buffers' })

    -- Open git in browser
    vim.keymap.set('n', '<leader>mgr', function()
      ---@diagnostic disable-next-line: missing-fields
      require('snacks').gitbrowse.open { what = 'repo' }
    end, { desc = 'Open git repo' })
    vim.keymap.set('n', '<leader>mgb', function()
      require('snacks').gitbrowse.open { what = 'branch' }
    end, { desc = 'Open git branch' })
    vim.keymap.set('n', '<leader>mgc', function()
      require('snacks').gitbrowse.open { what = 'commit' }
    end, { desc = 'Open git commit' })
    vim.keymap.set('n', '<leader>mgf', function()
      require('snacks').gitbrowse.open { what = 'file' }
    end, { desc = 'Open git file' })
    vim.keymap.set('n', '<leader>mgp', function()
      require('snacks').gitbrowse.open { what = 'permalink' }
    end, { desc = 'Open git permalink' })
  end,
}
