--- @type LazyPluginSpec
return { -- Collection of various small independent plugins/modules
  'nvim-mini/mini.nvim',
  dependencies = { 'ghostbuster91/nvim-next' },
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
            -- In english: starting at the transition from anything that's not
            -- an uppercase letter to an uppercase letter, take one or more
            -- uppercase letters, then take zero or more lowercase letters,
            -- ending at the transition to something that's not a lowercase
            -- letter. This pattern treats an uppercase letter as the end of a
            -- subword and requires at least one lowercase letter for the end
            -- transition.
            { '%f[%u]%u+[%l%d]*%f[^%d%l]', '^().*()$' },
            -- SNAKE_CASE_WORDS in uppercase
            -- Snake_Case_Words in titlecase
            -- regular UPPERCASE words
            -- Kebab-Case
            -- KEBAB-CASE (note: using %w at the end instead of %d%a breaks this case)
            -- In english: starting at the transition from anything that's not
            -- an uppercase letter to an uppercase letter, take one or more
            -- uppercase letters, then take zero or more lowercase letters,
            -- ending at the transition to something that's not a letter. This
            -- pattern treats separator characters like "_" and "-" as the end
            -- of a subword, and does not require a lowercase letter.
            { '%f[%u]%u+[%l%d]*%f[^%d%a]', '^().*()$' },
            -- start of camelCaseWords (just the `camel`)
            -- snake_case_words in lowercase
            -- regular lowercase words
            -- kebab-case
            -- In english: starting at the transition from anything that's not
            -- a letter to a letter, take one or more lowercase letters
            { '%f[%a%d][%l%d]+', '^().*()$' },
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

    local brack = require 'mini.bracketed'
    local conf = {
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
      diagnostic = { suffix = 'd', f = brack.diagnostic, options = {}, name = 'Diagnostic' },
      file = { suffix = '', options = {} },
      indent = { suffix = 'i', f = brack.indent, options = { change_type = 'diff' }, name = 'Indent' },
      jump = { suffix = 'j', f = brack.jump, options = {}, name = 'Jump in file' },
      location = { suffix = 'l', f = brack.location, options = {}, name = 'Location list item' },
      oldfile = { suffix = 'o', f = brack.oldfile, options = {}, name = 'Visited file' },
      quickfix = { suffix = 'q', f = brack.quickfix, options = {}, name = 'Quickfix item' },
      treesitter = { suffix = 't', f = brack.treesitter, options = {}, name = 'Treesitter element' },
      undo = { suffix = 'u', f = brack.undo, options = {}, name = 'Undo point' },
      window = { suffix = '', options = {} },
      yank = { suffix = 'y', f = brack.yank, options = {}, name = 'Yank history item' },
    }

    brack.setup(conf)

    -- Override the "backward/forward" mappings from bracketed with wrapped
    -- versions to make them repeatable with ; and ,
    --
    -- This only overrides the normal mode bindings; operator and visual mode
    -- bindings will work but won't be repeatable
    local move = require 'nvim-next.move'
    for _, target in pairs(conf) do
      if target.suffix ~= '' then
        -- We don't need to worry about passing the options because the options
        -- from the config become the defaults
        local prev, next = move.make_repeatable_pair(function(_)
          target.f 'backward'
        end, function(_)
          target.f 'forward'
        end)
        vim.keymap.set('n', '[' .. target.suffix, prev, { desc = target.name .. ' backward' })
        vim.keymap.set('n', ']' .. target.suffix, next, { desc = target.name .. ' forward' })
      end
    end

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
    statusline.setup {
      use_icons = vim.g.have_nerd_font,
      content = {
        active = function()
          local mode, mode_hl = MiniStatusline.section_mode { trunc_width = 120 }
          local git = MiniStatusline.section_git { trunc_width = 40 }
          local diff = MiniStatusline.section_diff { trunc_width = 75 }
          local diagnostics = MiniStatusline.section_diagnostics { trunc_width = 75 }
          local lsp = MiniStatusline.section_lsp { trunc_width = 75 }
          local filename = MiniStatusline.section_filename { trunc_width = 140 }
          local fileinfo = MiniStatusline.section_fileinfo { trunc_width = 120 }
          local location = MiniStatusline.section_location { trunc_width = 75 }
          local search = MiniStatusline.section_searchcount { trunc_width = 75 }

          local status = require('sidekick.status').get()
          local copilot_hl = status and (status.kind == 'Error' and 'DiagnosticError' or status.busy and 'DiagnosticWarn' or 'Special') or nil

          return MiniStatusline.combine_groups {
            { hl = mode_hl, string = { mode } },
            { hl = 'MiniStatuslineDevinfo', strings = { git, diff, diagnostics, lsp } },
            '%<', -- Mark general truncate point
            { hl = 'MiniStatuslineFilename', strings = { filename } },
            '%=', -- End left alignment
            { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
            { hl = mode_hl, strings = { search, location } },
            { hl = copilot_hl, strings = { ' ' } },
          }
        end,
      },
    }

    local miniclue = require 'mini.clue'
    local win_clues = miniclue.gen_clues.windows()
    -- TODO: this doesn't seem to capture any dynamic bindings like C-w d, just whatever is hardcoded into this map.
    local leader_w_clues = vim.deepcopy(win_clues)
    vim.tbl_map(function(c)
      c.keys = c.keys:gsub('^<C%-w>', '<Leader>w')
    end, leader_w_clues)
    miniclue.setup {
      window = { delay = 1200, config = { width = 'auto' } },
      triggers = {
        -- Leader triggers
        { mode = 'n', keys = '<Leader>' },
        { mode = 'x', keys = '<Leader>' },

        -- `[` and `]` keys
        { mode = 'n', keys = '[' },
        { mode = 'n', keys = ']' },

        -- Built-in completion
        { mode = 'i', keys = '<C-x>' },

        -- `g` key
        { mode = 'n', keys = 'g' },
        { mode = 'x', keys = 'g' },

        -- Marks
        { mode = 'n', keys = "'" },
        { mode = 'n', keys = '`' },
        { mode = 'x', keys = "'" },
        { mode = 'x', keys = '`' },

        -- Registers
        { mode = 'n', keys = '"' },
        { mode = 'x', keys = '"' },
        { mode = 'i', keys = '<C-r>' },
        { mode = 'c', keys = '<C-r>' },

        -- Window commands
        { mode = 'n', keys = '<C-w>' },
        -- { mode = 'n', keys = '<Leader>w' },

        -- `z` key
        { mode = 'n', keys = 'z' },
        { mode = 'x', keys = 'z' },
      },

      clues = {
        -- Enhance this by adding descriptions for <Leader> mapping groups
        miniclue.gen_clues.square_brackets(),
        miniclue.gen_clues.builtin_completion(),
        miniclue.gen_clues.g(),
        miniclue.gen_clues.marks(),
        miniclue.gen_clues.registers(),
        win_clues,
        leader_w_clues,
        miniclue.gen_clues.z(),
        { mode = 'n', keys = '<Leader>c', desc = '+Code' },
        { mode = 'n', keys = '<Leader>s', desc = '+Search' },
        { mode = 'x', keys = '<Leader>s', desc = '+Search (using selection)' },
        { mode = 'n', keys = '<Leader>t', desc = '+Toggle' },
        { mode = 'n', keys = '<Leader>td', desc = '+Debug' },
        { mode = 'n', keys = '<Leader>h', desc = '+Git Hunk' },
        { mode = 'x', keys = '<Leader>h', desc = '+Git Hunk (using selection)' },
        { mode = 'n', keys = '<Leader>m', desc = '+Misc' },
        { mode = 'x', keys = '<Leader>m', desc = '+Misc (using selection)' },
        { mode = 'n', keys = '<Leader>mg', desc = '+Git' },
        { mode = 'n', keys = '<Leader>ms', desc = '+Snippets' },
        { mode = 'n', keys = '<Leader>b', desc = '+Buffers' },
        { mode = 'n', keys = '<Leader>l', desc = '+Lists' },
        { mode = 'n', keys = '<Leader>u', desc = '+UI' },
        { mode = 'n', keys = '<Leader>g', desc = '+Git' },
      },
    }
    vim.cmd 'au FileType copilot-chat lua MiniClue.ensure_buf_triggers()'
  end,

  -- Try: comment
}
