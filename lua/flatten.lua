-- A pared-down version of
-- [flatten.nvim](https://github.com/willothy/flatten.nvim) for my use case of
-- just opening a new tab in the current neovim instance when git diffing from
-- the neovim terminal.
--
-- This works by running a different config when the $NVIM environment variable
-- is set (in the neovim terminal); in this case the neovim instance being
-- launched within the neovim terminal is called the "guest" instance, and its
-- config only passes along the command line arguments `vim.v.argv` and
-- `vim.v.argf` to the host (the instance running the terminal) via rpc. It
-- optionally blocks waiting for an rpc call from the host if the
-- `g:flatten_wait` variable is set.
--
-- Assuming the host has also loaded this module, it has the `host_receive`
-- function to be remotely-called by the guest, and this function executes the
-- commands from the guest. Currently it only runs pre and post commands and
-- opens buffers for vim.v.argf files with optional splits/tabs based -p/-o/-O,
-- and open diff splits if -d is provided. It could be extended like the
-- original flatten.nvim to handle stuff like quickfix and stdin but I don't
-- use these.
--
-- Example .gitconfig difftool:
--
-- ```toml
-- [difftool "nvim_difftool"]
-- # --cmd here for setting flatten_wait is important so the variable is set before the flatten module is loaded.
-- cmd = ~/scripts/nvim-cmd.sh --cmd \"let g:flatten_wait=1\" -c \"packadd nvim.difftool | tabnew | DiffTool $LOCAL $REMOTE\"
-- ```
--
-- Where nvim-cmd.sh looks something like:
--
-- ```sh
-- #!/bin/sh
--
-- # For use with a neovim config that forwards command line arguments to a host
-- # instance when it is run within a host neovim terminal (flattening the neovim
-- # instances)
-- if [ -z "$NVIM" ]; then
--   nvim "$@"
-- else
--   nvim --headless "$@"
-- fi
-- ```
--
-- `--headless` is not strictly necessary, but it avoids confusing terminal clearing.
--
-- The last piece is to add this to the top of `init.lua`:
--
-- ```lua
-- if require('flatten').setup() then
--   return
-- end
-- ```
local M = {}

--- The function argument, must not depend on upvalues, which means it can't
--- use local values itself; instead it must `require('...')` anything it uses.
---
---@param chan integer
---@param fn fun(...:any): ...:any
---@param args any[]
---@param blocking boolean
---@return any ...
local function exec_on_host(chan, fn, args, blocking)
  local req = vim.fn.rpcnotify
  if blocking then
    req = vim.fn.rpcrequest
  end

  local code = vim.base64.encode(string.dump(fn, true))

  local res = req(
    chan,
    'nvim_exec_lua',
    string.format(
      [[
      return loadstring(vim.base64.decode('%s'))(...)
    ]],
      code
    ),
    args
  )

  if blocking then
    return res
  end
end

---@param pipe_addr string
---@return boolean, integer
local function connect(pipe_addr)
  return pcall(vim.fn.sockconnect, 'pipe', pipe_addr, { rpc = true })
end

local waiting = false

local function sanitize(path)
  return path:gsub('\\', '/')
end

local function maybe_block(host, block)
  if not block then
    vim.cmd.qa { bang = true }
  end
  waiting = true
  local res, ctx = vim.wait(0X7FFFFFFF, function()
    return waiting == false or vim.api.nvim_get_chan_info(host) == vim.empty_dict()
  end, 200, false)
  if res then
    vim.cmd.qa { bang = true }
  elseif ctx == -2 then
    vim.notify('Waiting interrupted by user', vim.log.levels.WARN, { title = 'flatten.nvim' })
  end
end

function M.unblock()
  waiting = false
end

---@param guest_pipe string
local function unblock_guest(guest_pipe)
  local ok, response_sock = connect(guest_pipe)
  if not ok then
    vim.notify(string.format("Failed to connect to rpc host on '%s'.", guest_pipe), vim.log.levels.WARN, {
      title = 'flatten.nvim',
    })
    return
  end

  exec_on_host(response_sock, function()
    require('flatten').unblock()
  end, {}, false)
  if vim.api.nvim_get_chan_info(response_sock).id ~= nil then
    vim.fn.chanclose(response_sock)
  end
end

---@param pipe string
---@param winid integer
local function notify_when_done(pipe, winid)
  vim.api.nvim_create_autocmd({ 'WinClosed' }, {
    pattern = tostring(winid),
    once = true,
    callback = function()
      unblock_guest(pipe)
    end,
  })
end

---@param argv string[]
---@return string[] pre_cmds, string[] post_cmds
local function parse_argv(argv)
  local pre_cmds, post_cmds = {}, {}
  local is_cmd = false
  for _, arg in ipairs(argv) do
    if is_cmd then
      is_cmd = false
      table.insert(pre_cmds, arg)
    elseif arg:sub(1, 1) == '+' then
      local cmd = string.sub(arg, 2, -1)
      table.insert(post_cmds, cmd)
    elseif arg == '--cmd' or arg == '-c' then
      -- next arg is the actual command
      is_cmd = true
    end
  end
  return pre_cmds, post_cmds
end
function M.host_receive(opts)
  local response_pipe = opts.response_pipe
  local force_block = opts.force_block
  local argv = opts.argv
  local argf = opts.argf

  -- commands passed through with +<cmd>, to be executed after opening files
  local pre_cmds, post_cmds = parse_argv(argv)

  if #pre_cmds == 0 and #post_cmds == 0 and #argf == 0 then
    -- If there are no commands, don't open anything and tell the guest not to
    -- block
    return false
  end

  for _, cmd in ipairs(pre_cmds) do
    vim.api.nvim_exec2(cmd, {})
  end

  local is_diff = vim.tbl_contains(argv, '-d')
  local horizontal = vim.tbl_contains(argv, '-o')
  local vertical = vim.tbl_contains(argv, '-O')
  local tabs = vim.tbl_contains(argv, '-p')

  vim.cmd.tabnew()
  local split = horizontal and 'split' or 'vsplit'
  local edit_after_first = (is_diff or horizontal or vertical) and split or tabs and 'tabedit' or 'edit'
  local edit_command_opts = is_diff and '+diffthis' or ''
  for i, f in ipairs(argf) do
    if i == 1 then
      vim.cmd(vim.fn.join({ 'edit', edit_command_opts, f }, ' '))
    else
      vim.cmd(vim.fn.join({ edit_after_first, edit_command_opts, f }, ' '))
    end
  end

  local winid = vim.api.nvim_get_current_win()

  for _, cmd in ipairs(post_cmds) do
    vim.api.nvim_exec2(cmd, {})
  end

  if force_block then
    notify_when_done(response_pipe, winid)
  end

  return force_block
end

local function forward_to_host(host)
  local force_block = vim.g.flatten_wait ~= nil

  local server = vim.fn.fnameescape(vim.v.servername)
  if jit.os == 'Windows' then
    server = sanitize(server)
  end

  local args = {
    response_pipe = server,
    argv = vim.v.argv,
    argf = vim.v.argf,
    force_block = force_block,
  }

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    vim.api.nvim_buf_delete(buf, { force = true })
  end

  local block = exec_on_host(host, function(opts)
    return require('flatten').host_receive(opts)
  end, { args }, true) or force_block

  maybe_block(host, block)
end

local function guest_init(host_pipe)
  -- Avoid swapfile errors/warnings
  vim.g.updatecount = 0

  local host
  -- Connect to host process
  if type(host_pipe) == 'number' then
    host = host_pipe
  else
    local ok, chan = connect(host_pipe)
    if not ok then
      return
    end
    host = chan
  end

  vim.api.nvim_create_autocmd('BufEnter', {
    pattern = '*',
    once = true,
    callback = function()
      forward_to_host(host)
    end,
  })
end

---@return string | nil
local function pipe_path()
  if vim.env.NVIM then
    return vim.env.NVIM
  end
end

function M.setup()
  local pipe = pipe_path()
  if pipe == nil then
    return false
  end

  guest_init(pipe)
  return true
end

return M
