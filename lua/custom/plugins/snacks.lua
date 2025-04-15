---@type LazyPluginSpec
return {
  'folke/snacks.nvim',
  lazy = false,
  dependencies = {
    {
      'folke/todo-comments.nvim',
      optional = true,
      keys = {
        {
          '<leader>st',
          function()
            Snacks.picker.todo_comments()
          end,
          desc = 'Todo',
        },
        {
          '<leader>sT',
          function()
            Snacks.picker.todo_comments { keywords = { 'TODO', 'FIX', 'FIXME' } }
          end,
          desc = 'Todo/Fix/Fixme',
        },
      },
    },
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
    {
      '<leader><leader>',
      function()
        Snacks.picker.smart()
      end,
      desc = '[ ] Smart open',
    },
    {
      '<leader>s/',
      function()
        Snacks.picker.lines()
      end,
      desc = '[/] Fuzzily search in current buffer',
    },
    {
      '<leader>/',
      function()
        Snacks.picker.grep()
      end,
      desc = 'Grep',
    },
    {
      '<leader>sb',
      function()
        Snacks.picker.buffers()
      end,
      desc = '[S]earch [B]uffers',
    },
    {
      '<leader>sp',
      function()
        Snacks.picker.projects()
      end,
      desc = '[S]earch [P]rojects',
    },
    {
      '<leader>sf',
      function()
        Snacks.picker.files()
      end,
      desc = '[S]earch [F]iles',
    },
    {
      '<leader>sP',
      function()
        Snacks.picker.grep { cwd = vim.fn.stdpath 'data' .. '/lazy' }
      end,
      desc = 'Search plugin code',
    },
    {
      '<leader>s.',
      function()
        Snacks.picker.recent()
      end,
      desc = 'Recent files',
    },
    {
      '<leader>s?',
      function()
        Snacks.picker()
      end,
      desc = '[S]earch pickers',
    },
    {
      '<leader>:',
      function()
        Snacks.picker.command_history()
      end,
      desc = 'Command history',
    },
    {
      '<leader>s*',
      function()
        Snacks.picker.grep_word()
      end,
      desc = 'Visual selection or word',
      mode = { 'n', 'x' },
    },
    {
      '<leader>gb',
      function()
        Snacks.picker.git_branches()
      end,
      desc = 'Git Branches',
    },
    {
      '<leader>gl',
      function()
        Snacks.picker.git_log()
      end,
      desc = 'Git Log',
    },
    {
      '<leader>gL',
      function()
        Snacks.picker.git_log_line()
      end,
      desc = 'Git Log Line',
    },
    {
      '<leader>gs',
      function()
        Snacks.picker.git_status()
      end,
      desc = 'Git Status',
    },
    {
      '<leader>gS',
      function()
        Snacks.picker.git_stash()
      end,
      desc = 'Git Stash',
    },
    {
      '<leader>gd',
      function()
        Snacks.picker.git_diff()
      end,
      desc = 'Git Diff (Hunks)',
    },
    {
      '<leader>gf',
      function()
        Snacks.picker.git_log_file()
      end,
      desc = 'Git Log File',
    },
    {
      '<leader>sh',
      function()
        Snacks.picker.help()
      end,
      desc = 'Help Pages',
    },
    {
      '<leader>sr',
      function()
        Snacks.picker.resume()
      end,
      desc = 'Resume',
    },
    {
      '<leader>su',
      function()
        Snacks.picker.undo()
      end,
      desc = 'Undo History',
    },
    {
      '<leader>sd',
      function()
        Snacks.picker.diagnostics()
      end,
      desc = 'Diagnostics',
    },
    {
      '<leader>sD',
      function()
        Snacks.picker.diagnostics_buffer()
      end,
      desc = 'Buffer Diagnostics',
    },
    {
      'gd',
      function()
        Snacks.picker.lsp_definitions()
      end,
      desc = 'Goto Definition',
    },
    {
      'gD',
      function()
        Snacks.picker.lsp_declarations()
      end,
      desc = 'Goto Declaration',
    },
    {
      'grr',
      function()
        Snacks.picker.lsp_references()
      end,
      nowait = true,
      desc = 'References',
    },
    {
      'gI',
      function()
        Snacks.picker.lsp_implementations()
      end,
      desc = 'Goto Implementation',
    },
    {
      'gy',
      function()
        Snacks.picker.lsp_type_definitions()
      end,
      desc = 'Goto T[y]pe Definition',
    },
    {
      '<leader>ss',
      function()
        Snacks.picker.lsp_symbols()
      end,
      desc = 'LSP Symbols',
    },
    {
      '<leader>sS',
      function()
        Snacks.picker.lsp_workspace_symbols()
      end,
      desc = 'LSP Workspace Symbols',
    },
    {
      ']w',
      function()
        Snacks.words.jump(vim.v.count1)
      end,
      desc = 'Next Reference',
      mode = { 'n', 't' },
    },
    {
      '[w',
      function()
        Snacks.words.jump(-vim.v.count1)
      end,
      desc = 'Prev Reference',
      mode = { 'n', 't' },
    },
    {
      '<leader>N',
      desc = 'Neovim News',
      function()
        Snacks.win {
          file = vim.api.nvim_get_runtime_file('doc/news.txt', false)[1],
          width = 0.6,
          height = 0.6,
          wo = {
            spell = false,
            wrap = false,
            signcolumn = 'yes',
            statuscolumn = ' ',
            conceallevel = 3,
          },
        }
      end,
    },
    {
      '<leader>sn',
      function()
        Snacks.picker.notifications()
      end,
      desc = 'Notification History',
    },
    {
      '<leader>un',
      function()
        Snacks.notifier.hide()
      end,
      desc = 'Dismiss All Notifications',
    },
    {
      '<leader>sx',
      function()
        Snacks.scratch.select()
      end,
      desc = 'Select Scratch Buffer',
    },
  },
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    quickfile = { enabled = true }, -- When doing `nvim somefile.txt`, render the file as quickly as possible, before loading plugins
    indent = {
      enabled = true,
      -- Shows only the indent guide for the current scope
      indent = {
        enabled = false,
      },
      animate = {
        enabled = false,
      },
    },
    words = {},
    dashboard = { example = 'files' },
    input = {},
    picker = {
      layout = {
        -- reverse = true,
        preset = function()
          return vim.o.columns >= 120 and 'telescope' or 'vertical'
        end,
      },
      formatters = {
        file = {
          filename_first = true,
        },
      },
    },
    notifier = {},
    zen = {
      toggles = {
        dim = false,
      },
    },
  },
  init = function()
    -- Inform LSP about file rename in mini.files
    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesActionRename',
      callback = function(event)
        Snacks.rename.on_rename_file(event.data.from, event.data.to)
      end,
    })
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create some toggle mappings
        Snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>us'
        Snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>uw'
        Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map '<leader>uL'
        Snacks.toggle.option('foldenable', { name = 'Folding' }):map 'zi'
        Snacks.toggle.diagnostics():map '<leader>ud'
        Snacks.toggle.line_number():map '<leader>ul'
        Snacks.toggle.option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map '<leader>uc'
        Snacks.toggle.treesitter():map '<leader>uT'
        Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map '<leader>ub'
        Snacks.toggle.inlay_hints():map '<leader>uh'
        Snacks.toggle.indent():map '<leader>ug'
        Snacks.toggle.dim():map '<leader>uD'
        Snacks.toggle.zen():map '<leader>uz'
        Snacks.toggle.zoom():map '<leader>uZ'
        Snacks.toggle.animate():map '<leader>ua'
      end,
    })
  end,
}
