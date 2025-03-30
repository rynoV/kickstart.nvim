M = {}

-- These just call whatever is mapped to ][c, wrapped with nvim-next for repeatability.
-- These can be mapped at the global level so they work in diff mode, then reuse these functions
-- when overriding per buffer, for example with gitsigns
local next_move = require 'nvim-next.move'
local prev_change, next_change = next_move.make_repeatable_pair(function(_)
  vim.cmd.normal { '[c', bang = true }
end, function(_)
  vim.cmd.normal { ']c', bang = true }
end)

M.prev_change = prev_change
M.next_change = next_change

--- Use the qflist parsing to parse the line for a line number and column
--- Based on
--- https://github.com/neovim/neovim/issues/26128#issuecomment-1820590092
local function get_loc_at_cursor()
  local elems = vim.fn.getqflist({
    efm = vim.o.errorformat,
    lines = { vim.api.nvim_get_current_line() },
  }).items

  if #elems < 1 then
    return false
  else
    return true, elems[1].lnum, elems[1].col
  end
end

local function open_file_in_last_tab()
  -- Get the filename under cursor and prepare for processing
  local cfile = vim.fn.expand '<cfile>'
  local valid, lnum, col = get_loc_at_cursor()

  -- Check if last tab exists
  local last_tab = vim.fn.tabpagenr '#'
  if last_tab == 0 then
    vim.api.nvim_echo({ { 'No last accessed tab available', 'ErrorMsg' } }, true, {})
    return
  end

  -- Go to last tab
  vim.cmd('tabnext ' .. last_tab)

  -- Open the file
  vim.cmd('edit ' .. cfile)

  if valid then
    vim.api.nvim_win_set_cursor(0, { lnum, col })
    vim.cmd 'normal! zz' -- Center the view
  end
end

M.get_loc_at_cursor = get_loc_at_cursor
M.open_file_in_last_tab = open_file_in_last_tab

return M
