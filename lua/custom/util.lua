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
    -- Make sure some common formats are also recognized, file:line[:col]
    efm = vim.o.errorformat .. ',%f:%l:%c,%f:%l',
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

function M.term_enabled()
  -- Check if the current tab has a terminal window
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buf_type = vim.api.nvim_get_option_value('buftype', { buf = buf })
    if buf_type == 'terminal' then
      return true
    end
  end
  return false
end

function M.toggle_term()
  if M.term_enabled() then
    -- If current tab has a terminal, switch to last tab if it exists, else next tab
    if vim.fn.tabpagenr '#' ~= 0 then
      vim.cmd 'tabnext #'
    else
      vim.cmd 'tabnext'
    end
  else
    -- Check if any tab has a terminal window
    local term_tab_found = false
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.api.nvim_get_option_value('buftype', { buf = buf }) == 'terminal' then
          vim.api.nvim_set_current_tabpage(tab)
          term_tab_found = true
          break
        end
      end
      if term_tab_found then
        break
      end
    end

    -- If no terminal tab found, create a new one
    if not term_tab_found then
      vim.cmd 'tab term'
    end
  end
end

M.get_loc_at_cursor = get_loc_at_cursor
M.open_file_in_last_tab = open_file_in_last_tab

return M
