-- Adds git related signs to the gutter, as well as utilities for managing changes
-- NOTE: gitsigns is already included in init.lua but contains only the base
-- config. This will add also the recommended keymaps.

return {
  {
    'lewis6991/gitsigns.nvim',
    dependencies = {
      'ghostbuster91/nvim-next',
    },
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local next_integrations = require 'nvim-next.integrations'
        ---@module "gitsigns"
        local gitsigns = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end
        local nngs = next_integrations.gitsigns(gitsigns)

        local util = require 'custom.util'
        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            util.next_change()
          else
            nngs.next_hunk()
          end
        end, { desc = 'Jump to next git [c]hange' })

        map('n', '[c', function()
          if vim.wo.diff then
            util.prev_change()
          else
            nngs.prev_hunk()
          end
        end, { desc = 'Jump to previous git [c]hange' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'git [s]tage hunk' })
        map('v', '<leader>hr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'git [r]eset hunk' })
        -- normal mode
        map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git stage/unstage hunk' })
        map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
        map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
        map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
        map('n', '<leader>hP', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
        map('n', '<leader>hp', gitsigns.preview_hunk_inline, { desc = 'Preview hunk inline' })
        map('n', '<leader>hb', gitsigns.blame_line, { desc = 'git [b]lame line' })
        map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
        map('n', '<leader>hD', function()
          gitsigns.diffthis '@'
        end, { desc = 'git [D]iff against last commit' })
        map('n', '<leader>hq', function()
          gitsigns.setqflist('all', { use_location_list = false })
        end, { desc = 'Set quickfix list with hunks' })
        map('n', '<leader>hl', function()
          -- Current buffer only
          gitsigns.setqflist(0, { use_location_list = true })
        end, { desc = 'Set location list with hunks' })
        -- Toggles
        local config = require('gitsigns.config').config
        Snacks.toggle
          .new({
            name = 'Current line blame',
            get = function()
              return config.current_line_blame
            end,
            set = function(v)
              config.current_line_blame = v
              gitsigns.refresh()
            end,
          })
          :map '<leader>tb'
      end,
    },
  },
}
