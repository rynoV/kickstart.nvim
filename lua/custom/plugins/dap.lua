return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'williamboman/mason.nvim', -- Need to depend on mason so it updates PATH before we load the config
    'nvim-neotest/nvim-nio',
    'rcarriga/nvim-dap-ui',
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    ---@diagnostic disable-next-line: missing-fields
    dapui.setup {
      layouts = {
        {
          elements = {
            {
              id = 'scopes',
              size = 0.25,
            },
            {
              id = 'breakpoints',
              size = 0.25,
            },
            {
              id = 'stacks',
              size = 0.25,
            },
            {
              id = 'watches',
              size = 0.25,
            },
          },
          position = 'left',
          size = 40,
        },
        {
          elements = {
            {
              id = 'repl',
              size = 1.0,
            },
            -- The console is only useful for adapters that support integrated terminal (not .net)
            -- {
            --   id = 'console',
            --   size = 0.5,
            -- },
          },
          position = 'bottom',
          size = 10,
        },
      },
    }
    require('custom.dap_dotnet').setup {}

    dap.defaults.fallback.switchbuf = 'usevisible,uselast'

    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    vim.keymap.set('n', '<leader>tdb', dap.toggle_breakpoint, { desc = 'Breakpoint' })
    vim.keymap.set('n', '<leader>tdr', dap.repl.toggle, { desc = 'Breakpoint' })
    vim.keymap.set('n', '<leader>tdBB', dap.clear_breakpoints, { desc = 'Clear all breakpoints' })
    vim.keymap.set('n', '<leader>tdu', dapui.toggle, { desc = 'UI' })
    vim.keymap.set('n', '<leader>tdd', dap.run_last, { desc = 'Run last session' })
    vim.keymap.set('n', '<F4>', dap.restart, { desc = 'Debug restart' })
    vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug start/continue' })
    vim.keymap.set('n', '<F6>', dap.run_to_cursor, { desc = 'Debug run to cursor' })
    vim.keymap.set('n', '<F7>', dap.step_back, { desc = 'Debug step back' })
    vim.keymap.set({ 'n', 'v' }, '<F8>', function()
      ---@diagnostic disable-next-line: missing-fields
      dapui.eval(nil, { enter = true })
    end, { desc = 'Debug eval cursor/selection' })
    vim.keymap.set('n', '<F9>', function()
      dapui.float_element 'hover'
    end, { desc = 'Info for cursor' })
    vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'Debug step over' })
    vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'Debug step into' })
    vim.keymap.set('n', '<F12>', dap.step_out, { desc = 'Debug step out' })

    return {}
  end,
}
