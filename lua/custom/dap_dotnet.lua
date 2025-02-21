-- Based on https://github.com/NicholasMata/nvim-dap-cs/blob/16e5debe8cb7fb73c8799d20969ee00883586602/lua/dap-cs.lua
local M = {}

local default_config = {
  netcoredbg = {
    path = 'netcoredbg',
  },
}

local load_module = function(module_name)
  local ok, module = pcall(require, module_name)
  assert(ok, string.format('dap-dotnet dependency error: %s not installed', module_name))
  return module
end

local dap_pick_path = function(paths, opt)
  local path = opt.path
  local prompt = opt.prompt
  local co, ismain = coroutine.running()
  local ui = require 'dap.ui'
  local pick = (co and not ismain) and ui.pick_one or ui.pick_one_sync

  if not vim.endswith(path, '/') then
    path = path .. '/'
  end

  ---@param abspath string
  ---@return string
  local function relpath(abspath)
    local _, end_ = abspath:find(path)
    return end_ and abspath:sub(end_ + 1) or abspath
  end
  return pick(paths, prompt, relpath) or nil
end

local project_selection = function(project_path, proj_ext)
  local files = vim.fn.systemlist { 'fd', '--type', 'f', '--color', 'never', '--glob', '*.' .. proj_ext, project_path }
  return dap_pick_path(files, { path = project_path, prompt = 'Select project file:' })
end

local select_dll = function(root_path, proj_ext)
  local project_file = project_selection(root_path, proj_ext)
  if project_file == nil then
    return
  end
  local project_dir = vim.fn.fnamemodify(project_file, ':h')
  local project_name = vim.fn.fnamemodify(project_file, ':t:r')

  local bin_path = project_dir .. '/bin'

  local check_net_folders_cmd = { 'fd', '--type', 'd', '--color', 'never', '--case-sensitive', 'net.*', bin_path }
  local files = vim.fn.systemlist(check_net_folders_cmd)

  local net_bin = dap_pick_path(files, { path = bin_path, prompt = 'Select .net version:' })
  if net_bin == nil then
    return nil
  end

  local dll_path = net_bin .. '/' .. project_name .. '.dll'
  return dll_path
end

--- Attempts to pick a process smartly.
---
--- Does the following:
--- 1. Gets all project files
--- 2. Build filter
--- 2a. If a single project is found then will filter for processes ending with project name.
--- 2b. If multiple projects found then will filter for processes ending with any of the project file names.
--- 2c. If no project files found then will filter for processes starting with "dotnet"
--- 3. If a single process matches then auto selects it. If multiple found then displays it user for selection.
local smart_pick_process = function(dap_utils, project_path)
  local project_file = project_selection(project_path, true)
  if project_file == nil then
    return
  end

  local filter = function(proc)
    if type(project_file) == 'table' then
      for _, file in pairs(project_file) do
        local project_name = vim.fn.fnamemodify(file, ':t:r')
        if vim.endswith(proc.name, project_name) then
          return true
        end
      end
      return false
    elseif type(project_file) == 'string' then
      local project_name = vim.fn.fnamemodify(project_file, ':t:r')
      return vim.startswith(proc.name, project_name or 'dotnet')
    end
  end

  local processes = dap_utils.get_processes()
  processes = vim.tbl_filter(filter, processes)

  if #processes == 0 then
    print "No dotnet processes could be found automatically. Try 'Attach' instead"
    return
  end

  if #processes > 1 then
    return dap_utils.pick_process {
      filter = filter,
    }
  end

  return processes[1].pid
end

local setup_configuration = function(dap, dap_utils, config)
  local mk_configs = function(proj_file_ext)
    return {
      {
        type = 'coreclr',
        name = 'Launch',
        request = 'launch',
        program = function()
          local current_working_dir = vim.fn.getcwd()
          return select_dll(current_working_dir, proj_file_ext) or dap.ABORT
        end,
        justMyCode = false,
      },
      {
        type = 'coreclr',
        name = 'Attach',
        request = 'attach',
        processId = dap_utils.pick_process,
        justMyCode = false,
      },

      {
        type = 'coreclr',
        name = 'Attach (Smart)',
        request = 'attach',
        processId = function()
          local current_working_dir = vim.fn.getcwd()
          return smart_pick_process(dap_utils, current_working_dir) or dap.ABORT
        end,
        justMyCode = false,
      },
    }
  end
  dap.configurations.cs = mk_configs 'csproj'
  dap.configurations.fsharp = mk_configs 'fsproj'

  if config == nil or config.dap_configurations == nil then
    return
  end

  for _, dap_config in ipairs(config.dap_configurations) do
    if dap_config.type == 'coreclr' then
      table.insert(dap.configurations.cs, dap_config)
      table.insert(dap.configurations.fs, dap_config)
    end
  end
end

local setup_adapter = function(dap, config)
  dap.adapters.coreclr = {
    type = 'executable',
    command = config.netcoredbg.path,
    args = { '--interpreter=vscode' },
  }
end

function M.setup(opts)
  local config = vim.tbl_deep_extend('force', default_config, opts or {})
  local dap = load_module 'dap'
  local dap_utils = load_module 'dap.utils'
  setup_adapter(dap, config)
  setup_configuration(dap, dap_utils, config)
end

return M
