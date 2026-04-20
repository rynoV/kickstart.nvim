local M = {}

--- The function argument must not depend on upvalues, which means it can't
--- use local values itself; instead it must `require('...')` anything it uses.
---
---@param chan integer
---@param fn fun(...:any): ...:any
---@param args any[]
---@param blocking boolean
---@return any ...
function M.exec_on_host(chan, fn, args, blocking)
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
function M.connect(pipe_addr)
  return pcall(vim.fn.sockconnect, 'pipe', pipe_addr, { rpc = true })
end

return M
