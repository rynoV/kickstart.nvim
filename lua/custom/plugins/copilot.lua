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
            accept = false, -- Accepting is handled in the completions.lua keymap
            accept_word = '<M-l>',
            accept_line = '<M-Right>',
            next = '<M-\\>', -- use this to trigger
            prev = false,
            dismiss = '<C-]>',
          },
        },
      }
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
      model = 'claude-3.7-sonnet',
      highlight_headers = false,
      references_display = 'write',
      separator = '---',
      error_header = '> [!ERROR] Error',
      prompts = {
        CommitVerbose = {
          prompt = 'Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.',
          context = 'git:staged',
        },
        Commit = {
          prompt = 'Write a succinct commit message for the change. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.',
          context = 'git:staged',
        },
      },
    },
    keys = {
      { '<leader>tc', '<cmd>CopilotChatToggle<cr>', desc = 'Toggle Copilot Chat' },
      { '<leader>mc', '<cmd>CopilotChatCommit<cr>', desc = 'Commit message for staged changes' },
      { '<leader>cc', '<cmd>CopilotChatPrompts<cr>', desc = 'Copilot prompt' },
    },
  },
}
