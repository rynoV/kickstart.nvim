---@type LazyPluginSpec
return {
  'gbprod/yanky.nvim',
  dependencies = {
    'folke/snacks.nvim', -- For the snacks picker to self-register
  },
  opts = {
    ring = {
      permanent_wrapper = function(...)
        return require('yanky.wrappers').remove_carriage_return(...)
      end,
    },
    -- This is like :help vim.highlight.on_yank(), but also highlights on paste
    highlight = {
      timer = 150,
    },
    -- Similar to vim.keymap.set('n', 'gV', '`[v`]', { desc = 'Select last yank/paste' })
    -- but this is a textobject. Mapped to `iy` below
    textobj = {
      enabled = true,
    },
  },
  keys = {
    {
      -- Mappings: c-y to set register, c-x to delete
      '<leader>p',
      function()
        Snacks.picker.yanky()
      end,
      mode = { 'n', 'x' },
      desc = 'Open Yank History',
    },
    { 'y', '<Plug>(YankyYank)', mode = { 'n', 'x' }, desc = 'Yank text' },
    { 'p', '<Plug>(YankyPutAfter)', mode = { 'n', 'x' }, desc = 'Put yanked text after cursor' },
    { 'P', '<Plug>(YankyPutBefore)', mode = { 'n', 'x' }, desc = 'Put yanked text before cursor' },
    { 'gp', '<Plug>(YankyGPutAfter)', mode = { 'n', 'x' }, desc = 'Put yanked text after selection' },
    { 'gP', '<Plug>(YankyGPutBefore)', mode = { 'n', 'x' }, desc = 'Put yanked text before selection' },
    { '<c-p>', '<Plug>(YankyPreviousEntry)', desc = 'Select previous entry through yank history' },
    { '<c-n>', '<Plug>(YankyNextEntry)', desc = 'Select next entry through yank history' },
    { ']p', '<Plug>(YankyPutIndentAfterLinewise)', desc = 'Put indented after cursor (linewise)' },
    { '[p', '<Plug>(YankyPutIndentBeforeLinewise)', desc = 'Put indented before cursor (linewise)' },
    { ']P', '<Plug>(YankyPutIndentAfterLinewise)', desc = 'Put indented after cursor (linewise)' },
    { '[P', '<Plug>(YankyPutIndentBeforeLinewise)', desc = 'Put indented before cursor (linewise)' },
    { '>p', '<Plug>(YankyPutIndentAfterShiftRight)', desc = 'Put and indent right' },
    { '<p', '<Plug>(YankyPutIndentAfterShiftLeft)', desc = 'Put and indent left' },
    { '>P', '<Plug>(YankyPutIndentBeforeShiftRight)', desc = 'Put before and indent right' },
    { '<P', '<Plug>(YankyPutIndentBeforeShiftLeft)', desc = 'Put before and indent left' },
    { '=p', '<Plug>(YankyPutAfterFilter)', desc = 'Put after applying a filter' },
    { '=P', '<Plug>(YankyPutBeforeFilter)', desc = 'Put before applying a filter' },
    {
      'iy',
      function()
        require('yanky.textobj').last_put()
      end,
      mode = { 'o', 'x' },
      desc = 'Last put',
    },
  },
}
