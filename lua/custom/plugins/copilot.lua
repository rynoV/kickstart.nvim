return {
  {
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
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'zbirenbaum/copilot.lua' }, -- or zbirenbaum/copilot.lua
      { 'nvim-lua/plenary.nvim', branch = 'master' }, -- for curl, log and async functions
      { 'MeanderingProgrammer/render-markdown.nvim', opts = {
        file_types = { 'markdown', 'copilot-chat' },
      } },
    },
    -- build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      model = 'claude-3.5-sonnet',
      auto_insert_mode = true,
      insert_at_end = true,
      highlight_headers = false,
      separator = '---',
      error_header = '> [!ERROR] Error',
      prompts = {
        CommitVerbose = {
          prompt = '> #git:staged\n\nWrite commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.',
        },
        Commit = {
          prompt = '> #git:staged\n\nWrite a succinct commit message for the change. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.',
        },
      },
    },
    keys = {
      { '<leader>tc', '<cmd>CopilotChatToggle<cr>', desc = 'Toggle Copilot Chat' },
      { '<leader>mc', '<cmd>CopilotChatCommit<cr>', desc = 'Commit message for staged changes' },
    },
  },
}
