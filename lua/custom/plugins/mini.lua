--- @type LazyPluginSpec[]
return { -- Collection of various small independent plugins/modules
  {
    'nvim-mini/mini.icons',
    config = function()
      require('mini.icons').setup {}
    end,
  },
  {
    'nvim-mini/mini.sessions',
    config = function()
      -- Call "write" to start saving a local session, then the session will be auto saved and read
      local mini_sessions = require 'mini.sessions'
      mini_sessions.setup { autoread = true }

      vim.keymap.set('n', '<leader>mS', function()
        mini_sessions.write(mini_sessions.config.file)
      end, { desc = 'Save local session' })
    end,
  },
  {
    'nvim-mini/mini.operators',
    config = function()
      -- gs: sort
      -- gx: exchange
      -- g=: evaluate
      -- gr: replace with register
      -- gm: multiply
      require('mini.operators').setup {
        replace = { prefix = 'cr' },
      }
    end,
  },
  {
    'nvim-mini/mini.extra',
    config = function()
      require('mini.extra').setup()
    end,
  },
  {
    'nvim-mini/mini.ai',
    dependencies = { 'nvim-mini/mini.extra' },
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup {
        n_lines = 500,
        custom_textobjects = {
          l = MiniExtra.gen_ai_spec.line(),
          i = MiniExtra.gen_ai_spec.indent(),
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
    end,
  },
  {
    'nvim-mini/mini.surround',
    config = function()
      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup { n_lines = 500 }
    end,
  },
  {
    'nvim-mini/mini.bracketed',
    dependencies = { 'ghostbuster91/nvim-next' },
    config = function()
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
        diagnostic = { suffix = 'd', f = brack.diagnostic, options = { severity = { min = vim.diagnostic.severity.WARN } }, name = 'Diagnostic' },
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
    end,
  },
  {
    'nvim-mini/mini.files',
    config = function()
      require('mini.files').setup {}

      vim.keymap.set('n', '<leader>tf', require('mini.files').open, { desc = 'File explorer' })
      vim.keymap.set('n', '<leader>tF', function()
        require('mini.files').open(vim.api.nvim_buf_get_name(0))
      end, { desc = 'File explorer focus current file' })

      -- Centered layout from: https://github.com/nvim-mini/mini.nvim/discussions/2173#discussioncomment-15272407
      -- Window width based on the offset from the center, i.e. center window
      -- is 60, then next over is 20, then the rest are 10.
      -- Can use more resolution if you want like { 60, 20, 20, 10, 5 }
      local widths = { 60, 20, 10 }

      local ensure_center_layout = function(ev)
        local state = MiniFiles.get_explorer_state()
        if state == nil then
          return
        end

        -- Compute "depth offset" - how many windows are between this and focused
        local path_this = vim.api.nvim_buf_get_name(ev.data.buf_id):match '^minifiles://%d+/(.*)$'
        local depth_this
        for i, path in ipairs(state.branch) do
          if path == path_this then
            depth_this = i
          end
        end
        if depth_this == nil then
          return
        end
        local depth_offset = depth_this - state.depth_focus

        -- Adjust config of this event's window
        local i = math.abs(depth_offset) + 1
        local win_config = vim.api.nvim_win_get_config(ev.data.win_id)
        win_config.width = i <= #widths and widths[i] or widths[#widths]

        win_config.zindex = 99
        win_config.col = math.floor(0.5 * (vim.o.columns - widths[1]))
        local sign = depth_offset == 0 and 0 or (depth_offset > 0 and 1 or -1)
        for j = 1, math.abs(depth_offset) do
          -- widths[j+1] for the negative case because we don't want to add the center window's width
          local prev_win_width = (sign == -1 and widths[j + 1]) or widths[j] or widths[#widths]
          -- Add an extra +2 each step to account for the border width
          local new_col = win_config.col + sign * (prev_win_width + 2)
          if (new_col < 0) or (new_col + win_config.width > vim.o.columns) then
            win_config.zindex = win_config.zindex - 1
            break
          end
          win_config.col = new_col
        end

        win_config.height = depth_offset == 0 and 24 or 20
        win_config.row = math.floor(0.5 * (vim.o.lines - win_config.height))
        -- win_config.border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" }
        win_config.footer = { { tostring(depth_offset), 'Normal' } }
        vim.api.nvim_win_set_config(ev.data.win_id, win_config)
      end

      vim.api.nvim_create_autocmd('User', { pattern = 'MiniFilesWindowUpdate', callback = ensure_center_layout })
    end,
  },
  {
    'nvim-mini/mini-git',
    config = function()
      require('mini.git').setup {}

      vim.cmd 'au FileType diff,git setlocal foldmethod=expr foldexpr=v:lua.MiniGit.diff_foldexpr()'
    end,
  },
  {
    'nvim-mini/mini.statusline',
    config = function()
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

            local sidekick_loaded = package.loaded.sidekick

            local sidekick_group = function()
              local sidekick_status = require('sidekick.status').get()
              local sidekick_cli_status = require('sidekick.status').cli()
              local copilot_hl = sidekick_status
                  and (sidekick_status.kind == 'Error' and 'DiagnosticError' or sidekick_status.busy and 'DiagnosticWarn' or 'Special')
                or nil
              return { hl = copilot_hl, strings = { ' ' .. (#sidekick_cli_status > 0 and '[' .. #sidekick_cli_status .. ']' or '') } }
            end

            return MiniStatusline.combine_groups {
              { hl = mode_hl, strings = { mode } },
              { hl = 'MiniStatuslineDevinfo', strings = { git, diff, diagnostics, lsp } },
              '%<', -- Mark general truncate point
              { hl = 'MiniStatuslineFilename', strings = { filename } },
              '%=', -- End left alignment
              sidekick_loaded and sidekick_group() or {},
              { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
              { hl = mode_hl, strings = { search, location } },
            }
          end,
        },
      }
    end,
  },
  {
    'nvim-mini/mini.clue',
    config = function()
      local miniclue = require 'mini.clue'
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
          miniclue.gen_clues.windows(),
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
          { mode = 'n', keys = '<Leader>n', desc = '+Notes' },
          { mode = 'n', keys = '<Leader>a', desc = '+AI' },
          { mode = 'n', keys = '<Leader>b', desc = '+Buffers' },
          { mode = 'n', keys = '<Leader>l', desc = '+Lists' },
          { mode = 'n', keys = '<Leader>u', desc = '+UI' },
          { mode = 'n', keys = '<Leader>g', desc = '+Git' },
        },
      }
      vim.cmd 'au FileType copilot-chat lua MiniClue.ensure_buf_triggers()'
    end,
  },
  {
    'nvim-mini/mini.hipatterns',
    config = function()
      local hipatterns = require 'mini.hipatterns'
      hipatterns.setup {
        highlighters = {
          -- Highlight hex color strings (eg `#8fbcbb`) using that color
          hex_color = hipatterns.gen_highlighter.hex_color(),
        },
      }
    end,
  },
  {
    'nvim-mini/mini.cursorword',
    config = function()
      require('mini.cursorword').setup()
    end,
  },
  {
    'nvim-mini/mini.misc',
    config = function()
      require('mini.misc').setup()

      MiniMisc.setup_restore_cursor()
      MiniMisc.setup_termbg_sync()
      -- MiniMisc.setup_auto_root()
    end,
  },
  {
    'nvim-mini/mini.cmdline',
    enabled = false,
    config = function()
      require('mini.cmdline').setup {
        autocomplete = {
          delay = 500,
        },
      }
    end,
  },
}
