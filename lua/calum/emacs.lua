--- Module for sending commands to the emacs frame in the emacs tab. This works
--- by invoking functions in emacs that scope their actions to the frame with
--- the NVIM socket matching this neovim instance.
local M = {}

local tabs = require 'calum.tabs'

local retry_delay = 50
local max_retries = 40

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = 'Emacs/Magit' })
end

local function nvim_socket()
  local socket = vim.env.NVIM
  if not socket or socket == '' then
    socket = vim.v.servername
  end

  if not socket or socket == '' then
    notify('No Neovim RPC socket is available', vim.log.levels.ERROR)
    return
  end

  return socket
end

local function elisp_literal(value)
  if type(value) == 'string' then
    return vim.json.encode(value)
  end

  if type(value) == 'number' then
    return tostring(value)
  end

  error('Unsupported Emacs Lisp argument type: ' .. type(value))
end

local function make_eval(function_name, ...)
  local arguments = { ... }
  local encoded = vim.tbl_map(elisp_literal, arguments)
  if #encoded == 0 then
    return '(' .. function_name .. ')'
  end
  return '(' .. function_name .. ' ' .. table.concat(encoded, ' ') .. ')'
end

local function dispatch(expression)
  if vim.fn.executable 'emacsclient' ~= 1 then
    notify('emacsclient is not executable', vim.log.levels.ERROR)
    return
  end

  vim.system({ 'emacsclient', '-a', '', '-u', '--eval', expression }, { text = true }, function(result)
    if result.code == 0 then
      return
    end

    local details = vim.trim(result.stderr or '')
    if details == '' then
      details = 'exit code ' .. result.code
    end
    vim.schedule(function()
      notify('Emacs command failed: ' .. details, vim.log.levels.ERROR)
    end)
  end)
end

local function dispatch_when_ready(function_name, ...)
  local socket = nvim_socket()
  if not socket then
    return
  end

  if not tabs.is_emacs() then
    tabs.new_emacs()
  end

  local arguments = { ... }
  local retries = 0
  local function wait_for_emacs()
    if tabs.is_emacs() then
      dispatch(make_eval(function_name, socket, unpack(arguments)))
      return
    end

    retries = retries + 1
    if retries >= max_retries then
      notify('Timed out waiting for the Emacs tab to start', vim.log.levels.ERROR)
      return
    end

    vim.defer_fn(wait_for_emacs, retry_delay)
  end

  wait_for_emacs()
end

local function current_file_context()
  if vim.bo.buftype ~= '' then
    notify('The current buffer is not a file', vim.log.levels.ERROR)
    return
  end

  local path = vim.api.nvim_buf_get_name(0)
  if path == '' then
    notify('The current buffer has no file', vim.log.levels.ERROR)
    return
  end

  path = vim.fs.normalize(vim.fs.abspath(path))
  local stat = vim.uv.fs_stat(path)
  if not stat or stat.type ~= 'file' then
    notify('The current buffer does not name a regular file', vim.log.levels.ERROR)
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  return path, cursor[1], 0, vim.fs.normalize(vim.fn.getcwd())
end

function M.goto_magit_file_position()
  local path, line, column, cwd = current_file_context()
  if not path then
    return
  end

  dispatch_when_ready('calum/nvim-magit-file-position', cwd, path, line, column)
end

function M.magit_status()
  dispatch_when_ready('calum/nvim-magit-status', vim.fs.normalize(vim.fn.getcwd()))
end

function M.refresh_magit_status()
  dispatch_when_ready 'calum/nvim-magit-refresh'
end

return M
