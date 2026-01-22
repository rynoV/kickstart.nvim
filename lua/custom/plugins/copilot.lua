--- @type LazySpec
return {
  {
    'copilotlsp-nvim/copilot-lsp',
    enabled = false,
    lazy = false,
    config = function()
      vim.g.copilot_nes_debounce = 500
      vim.lsp.enable 'copilot_ls'
    end,
    keys = {
      {
        '<tab>',
        function()
          local bufnr = vim.api.nvim_get_current_buf()
          local state = vim.b[bufnr].nes_state
          if state then
            -- Try to jump to the start of the suggestion edit.
            -- If already at the start, then apply the pending suggestion and jump to the end of the edit.
            local _ = require('copilot-lsp.nes').walk_cursor_start_edit()
              or (require('copilot-lsp.nes').apply_pending_nes() and require('copilot-lsp.nes').walk_cursor_end_edit())
            return nil
          else
            -- Resolving the terminal's inability to distinguish between `TAB` and `<C-i>` in normal mode
            return '<C-i>'
          end
        end,
        desc = 'Accept Copilot NES suggestion',
        expr = true,
      },
      {
        '<esc>',
        function()
          if not require('copilot-lsp.nes').clear() then
            return '<esc>'
          end
        end,
        desc = 'Clear Copilot suggestion or fallback',
        expr = true,
      },
    },
  },
  {
    'zbirenbaum/copilot.lua',
    enabled = false,
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
    enabled = false,
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
      selection = function(source)
        local select = require 'CopilotChat.select'
        return select.visual(source)
      end,
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
      { '<leader>mC', '<cmd>CopilotChatPrompts<cr>', mode = { 'n', 'x' }, desc = 'Copilot prompt' },
    },
  },
}
