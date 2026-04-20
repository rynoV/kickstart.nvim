local M = {}

---@param pipe string
---@param winid integer
local function notify_when_done(pipe, winid)
  vim.api.nvim_create_autocmd({ 'WinClosed' }, {
    pattern = tostring(winid),
    once = true,
    callback = function()
      require('calum.flatten.guest').unblock_guest(pipe)
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
  local stdin = opts.stdin or {}

  -- commands passed through with +<cmd>, to be executed after opening files
  local pre_cmds, post_cmds = parse_argv(argv)

  if #pre_cmds == 0 and #post_cmds == 0 and #argf == 0 and #stdin == 0 then
    -- If there are no commands, don't open anything and tell the guest not to
    -- block
    return false
  end

  for _, cmd in ipairs(pre_cmds) do
    vim.api.nvim_exec2(cmd, {})
  end

  vim.cmd.tabnew()

  if #stdin > 0 then
    local bufnr = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, 0, true, stdin)
    vim.api.nvim_set_current_buf(bufnr)
  end

  local is_diff = vim.tbl_contains(argv, '-d')
  local horizontal = vim.tbl_contains(argv, '-o')
  local vertical = vim.tbl_contains(argv, '-O')
  local tabs = vim.tbl_contains(argv, '-p')

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

return M
