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
    dapui.setup {}
    require('custom.dap_dotnet').setup {}

    dap.defaults.fallback.switchbuf = 'usevisible,uselast'

    -- local netcoredbg = vim.fn.exepath 'netcoredbg'
    -- if netcoredbg ~= '' then
    --   dap.adapters.coreclr = {
    --     type = 'executable',
    --     command = 'netcoredbg',
    --     args = { '--interpreter=vscode' },
    --   }
    --   dap.configurations.fsharp = {
    --     {
    --       type = 'coreclr',
    --       name = 'run',
    --       request = 'launch',
    --       program = 'run',
    --       args = function()
    --         -- Executables=false seems to be necessary for the dll to be found
    --         local project = require('dap.utils').pick_file { filter = '.*%.fsproj', executables = false }
    --         return (project and project ~= '') and { '--project', project } or dap.ABORT
    --       end,
    --     },
    --     {
    --       type = 'coreclr',
    --       name = 'launch - netcoredbg',
    --       request = 'launch',
    --       program = function()
    --         -- Executables=false seems to be necessary for the dll to be found
    --         local path = require('dap.utils').pick_file { filter = '.*%.dll', executables = false }
    --         return (path and path ~= '') and path or dap.ABORT
    --       end,
    --     },
    --   }
    -- end

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
    return {}
  end,
}
