return {
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  event = 'InsertEnter',
  config = function()
    require('copilot').setup {
      suggestion = {
        enabled = true,
        auto_trigger = false,
        hide_during_completion = true,
        debounce = 75,
        keymap = {
          accept = false, -- Completion trigger is defined with nvim-cmp based on https://github.com/zbirenbaum/copilot.lua/issues/91#issuecomment-1345190310
          accept_word = '<M-l>',
          accept_line = '<M-Right>',
          next = '<M-\\>', -- use this to trigger
          prev = false,
          dismiss = '<C-]>',
        },
      },
    }

    if pcall(require, 'cmp') then
      local cmp = require 'cmp'

      cmp.event:on('menu_opened', function()
        vim.b.copilot_suggestion_hidden = true
      end)

      cmp.event:on('menu_closed', function()
        vim.b.copilot_suggestion_hidden = false
      end)
    end
  end,
}
