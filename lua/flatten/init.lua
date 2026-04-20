-- A pared-down version of
-- [flatten.nvim](https://github.com/willothy/flatten.nvim) for my use case
-- where the terminal is in its own tab.
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
-- and open diff splits if -d is provided.
--
-- It also has basic support for stdin, just tested for use as `MANPAGER="nvim +Man!"`
-- (opens stdin as a scratch buffer, probably won't work well if pairing stdin
-- with other files on the command line).
--
-- Example .gitconfig difftool:
--
-- ```toml
-- [difftool "nvim_difftool"]
-- # --cmd here for setting flatten_wait is important so the variable is set before the flatten module is loaded.
-- # "+" is important so the diff command runs after the new tab page is opened
-- cmd = ~/scripts/nvim-cmd.sh --cmd \"let g:flatten_wait=1\" +\"packadd nvim.difftool | DiffTool $LOCAL $REMOTE\"
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
--
-- You can set `VISUAL="~/scripts/nvim-cmd.sh --cmd 'let g:flatten_wait=1'"`,
-- and some programs which respect the VISUAL environment variable (e.g.
-- chezmoi) will end up integrating nicely with the running neovim instance.
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

  vim.api.nvim_create_autocmd('StdinReadPost', {
    pattern = '*',
    callback = function()
      local readlines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
      require('flatten.guest').forward_to_host(host, readlines)
    end,
  })

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
