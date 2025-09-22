return { -- Collection of various small independent plugins/modules
  'nvim-mini/mini.nvim',
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
    require('mini.ai').setup {
      n_lines = 500,
      custom_textobjects = {
        -- "subword" text object.. snake_case, camelCase, PascalCase, etc; all capitalizations
        s = {
          -- Based on https://github.com/nvim-mini/mini.nvim/discussions/1434
          -- Lua 5.1 character classes and the undocumented frontier pattern:
          -- https://www.lua.org/manual/5.1/manual.html#5.4.1
          -- http://lua-users.org/wiki/FrontierPattern
          {
            -- PascalCaseWords (or the latter part of camelCaseWords)
            -- Snake_Case_Words in titlecase
            -- regular UPPERCASE words
            { '%f[%u]%u+[%l%d]*%f[^%d%l]', '^().*()$' },
            -- SNAKE_CASE_WORDS in uppercase
            { '%f[%u]%u+[%l%d]*%f[^%w]', '^().*()$' },
            -- start of camelCaseWords (just the `camel`)
            -- snake_case_words in lowercase
            -- regular lowercase words
            { '%f[^%s%p][%l%d]+', '^().*()$' },
          },
        },
      },
    }

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup { n_lines = 500 }

    require('mini.bracketed').setup {
      -- First-level elements are tables describing behavior of a target:
      --
      -- - <suffix> - single character suffix. Used after `[` / `]` in mappings.
      --   For example, with `b` creates `[B`, `[b`, `]b`, `]B` mappings.
      --   Supply empty string `''` to not create mappings.
      --
      -- - <options> - table overriding target options.
      --
      -- See `:h MiniBracketed.config` for more info.
      buffer = { suffix = '', options = {} },
      comment = { suffix = '', options = {} },
      conflict = { suffix = '', options = {} },
      diagnostic = { suffix = '', options = {} },
      file = { suffix = '', options = {} },
      indent = { suffix = 'i', options = { change_type = 'diff' } },
      jump = { suffix = '', options = {} },
      location = { suffix = '', options = {} },
      oldfile = { suffix = 'o', options = {} },
      quickfix = { suffix = '', options = {} },
      treesitter = { suffix = 't', options = {} },
      undo = { suffix = 'u', options = {} },
      window = { suffix = '', options = {} },
      yank = { suffix = 'y', options = {} },
    }

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
  end,
}
