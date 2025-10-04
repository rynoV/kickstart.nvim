-- Open line below/above with comment. Commenting empty lines is not supported
-- with built-in vim comment support, so we type a character, comment the line,
-- and delete the character.
-- We need to use :normal or switching between insert
-- and normal mode in the mapping doesn't work.
-- Note if we're in a comment already, this will instead open a line without a
-- comment (if comments are configured to be inserted automatically when
-- opening a line), which might be nice instead of using "o<C-u>"
vim.keymap.set('n', 'gco', '<Cmd>:normal oa<C-o>gcc<CR>$cl', { desc = 'Open line below with comment' })
vim.keymap.set('n', 'gcO', '<Cmd>:normal Oa<C-o>gcc<CR>$cl', { desc = 'Open line above with comment' })
-- Open comment below, go back up to current line, join the lines, and insert
-- at the end of the line
vim.keymap.set('n', 'gca', '<Cmd>:normal gco<CR>kJA', { desc = 'Add comment at end of line' })

return {
  'numToStr/Comment.nvim',
  enabled = false,
  dependencies = {
    'JoosepAlviste/nvim-ts-context-commentstring',
    opts = {
      enable_autocmd = false,
    },
  },
  opts = function(_, opts)
    opts.pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()
    return opts
  end,
}
