return { -- Collection of various small independent plugins/modules
  'echasnovski/mini.nvim',
  config = function()
    -- Call "write" to start saving a local session, then the session will be auto saved and read
    local mini_sessions = require 'mini.sessions'
    mini_sessions.setup { autoread = true }

    vim.keymap.set('n', '<leader>mS', function()
      mini_sessions.write(mini_sessions.config.file)
    end, { desc = 'Save local session' })

    -- gs: sort
    -- gx: exchange
    -- g=: evaluate
    -- gr: replace with register
    -- gm: multiply
    require('mini.operators').setup {
      replace = { prefix = 'cr' },
    }

    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    --  - ci'  - [C]hange [I]nside [']quote
    require('mini.ai').setup { n_lines = 500 }

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup()

    require('mini.files').setup {}

    vim.keymap.set('n', '<leader>tf', require('mini.files').open, { desc = 'File explorer' })
    vim.keymap.set('n', '<leader>tF', function()
      require('mini.files').open(vim.api.nvim_buf_get_name(0))
    end, { desc = 'File explorer focus current file' })

    -- Simple and easy statusline.
    --  You could remove this setup call if you don't like it,
    --  and try some other statusline plugin
    local statusline = require 'mini.statusline'
    -- set use_icons to true if you have a Nerd Font
    statusline.setup { use_icons = vim.g.have_nerd_font }

    -- You can configure sections in the statusline by overriding their
    -- default behavior. For example, here we set the section for
    -- cursor location to LINE:COLUMN
    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function()
      return '%2l:%-2v'
    end

    -- ... and there is more!
    --  Check out: https://github.com/echasnovski/mini.nvim
  end,
}
