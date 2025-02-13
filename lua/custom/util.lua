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

return M
