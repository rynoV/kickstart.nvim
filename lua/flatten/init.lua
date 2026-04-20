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

local function guest_init(host_pipe)
  -- Avoid swapfile errors/warnings
  vim.g.updatecount = 0

  local host
  -- Connect to host process
  if type(host_pipe) == 'number' then
    host = host_pipe
  else
    local ok, chan = require('flatten.rpc').connect(host_pipe)
    if not ok then
      return
    end
    host = chan
  end

  vim.api.nvim_create_autocmd('BufEnter', {
    pattern = '*',
    once = true,
    callback = function()
      require('flatten.guest').forward_to_host(host)
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
