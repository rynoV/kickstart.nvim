if require('calum.flatten').setup() then
  return
end

if vim.loader then
  -- Seems to take about 10ms off startup at time of writing
  vim.loader.enable()
end

require('vim._core.ui2').enable()

-- Setup some globals for debugging (lazy-loaded)
_G.dd = function(...)
  Snacks.debug.inspect(...)
end
_G.bt = function()
  Snacks.debug.backtrace()
end
-- Override print to use snacks for `:=` command
---@diagnostic disable-next-line: duplicate-set-field
vim._print = function(_, ...)
  dd(...)
end

if vim.env.PROF then
  -- Assumes lazy.nvim
  local snacks = vim.fn.stdpath 'data' .. '/lazy/snacks.nvim'
  vim.opt.rtp:append(snacks)
  require('snacks.profiler').startup {
    startup = {
      event = 'VimEnter', -- stop profiler on this event. Defaults to `VimEnter`
      -- event = "UIEnter",
      -- event = "VeryLazy",
    },
  }
end

require 'config.options'

vim.api.nvim_create_autocmd('User', {
  pattern = 'VeryLazy',
  callback = function()
    require 'config.keymaps'
    require 'config.autocmds'
  end,
})

require 'config.lazy'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
