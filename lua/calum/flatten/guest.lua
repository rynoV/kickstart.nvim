local M = {}

local waiting = false

local function sanitize(path)
  return path:gsub('\\', '/')
end

function M.unblock()
  waiting = false
end

---@param guest_pipe string
function M.unblock_guest(guest_pipe)
  local ok, response_sock = require('calum.flatten.rpc').connect(guest_pipe)
  if not ok then
    vim.notify(string.format("Failed to connect to rpc host on '%s'.", guest_pipe), vim.log.levels.WARN, {
      title = 'flatten',
    })
    return
  end

  require('calum.flatten.rpc').exec_on_host(response_sock, function()
    require('calum.flatten.guest').unblock()
  end, {}, false)
  if vim.api.nvim_get_chan_info(response_sock).id ~= nil then
    vim.fn.chanclose(response_sock)
  end
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

function M.forward_to_host(host, stdin)
  local force_block = vim.g.flatten_wait ~= nil

  local server = vim.fn.fnameescape(vim.v.servername)
  if jit.os == 'Windows' then
    server = sanitize(server)
  end

  local args = {
    response_pipe = server,
    argv = vim.v.argv,
    argf = vim.v.argf,
    stdin = stdin,
    force_block = force_block,
  }

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    vim.api.nvim_buf_delete(buf, { force = true })
  end

  local block = require('calum.flatten.rpc').exec_on_host(host, function(opts)
    return require('calum.flatten.host').host_receive(opts)
  end, { args }, true) or force_block

  maybe_block(host, block)
end

return M
