return {
  'folke/snacks.nvim',
  ---@type snacks.Config
  opts = {
    bigfile = {
      enabled = true,
    },
    quickfile = {
      enabled = true,
    }, -- When doing `nvim somefile.txt`, render the file as quickly as possible, before loading plugins
  },
  keys = {
    {
      '<leader>ts',
      function()
        ---@diagnostic disable-next-line: missing-fields
        Snacks.scratch { ft = 'markdown' }
      end,
      desc = '[S]cratch Buffer',
    },
    {
      '<leader>tS',
      function()
        Snacks.scratch.select()
      end,
      desc = '[S]elect [S]cratch Buffer',
    },
    -- Open git in browser
    {
      '<leader>mgr',
      function()
        ---@diagnostic disable-next-line: missing-fields
        require('snacks').gitbrowse.open { what = 'repo' }
      end,
      desc = 'Open git repo',
    },
    {
      '<leader>mgb',
      function()
        ---@diagnostic disable-next-line: missing-fields
        require('snacks').gitbrowse.open { what = 'branch' }
      end,
      desc = 'Open git branch',
    },
    {
      '<leader>mgc',
      function()
        ---@diagnostic disable-next-line: missing-fields
        require('snacks').gitbrowse.open { what = 'commit' }
      end,
      desc = 'Open git commit',
    },
    {
      '<leader>mgf',
      function()
        ---@diagnostic disable-next-line: missing-fields
        require('snacks').gitbrowse.open { what = 'file' }
      end,
      desc = 'Open git file',
    },
    {
      '<leader>mgp',
      function()
        ---@diagnostic disable-next-line: missing-fields
        require('snacks').gitbrowse.open { what = 'permalink' }
      end,
      desc = 'Open git permalink',
    },
    -- Delete buffer without affecting windows/tabs
    {
      '<leader>bd',
      function()
        require('snacks').bufdelete.delete()
      end,
      desc = 'Delete buffer',
    },
    {
      '<leader>bO',
      function()
        require('snacks').bufdelete.other()
      end,
      desc = 'Delete other buffers',
    },
    {
      '<leader>bA',
      function()
        require('snacks').bufdelete.all()
      end,
      desc = 'Delete all buffers',
    },
  },
  config = function()
    -- Inform LSP about file rename in mini.files
    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesActionRename',
      callback = function(event)
        Snacks.rename.on_rename_file(event.data.from, event.data.to)
      end,
    })
  end,
}
