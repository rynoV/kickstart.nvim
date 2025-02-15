-- Comment settings
vim.opt_local.formatoptions = 'croql'
vim.opt_local.comments = 's0:*,m0:*,ex0:*),s1:(*,mb:*,ex:*),:///,://'
-- Useful if not handled by another plugin
-- vim.opt_local.commentstring = '// %s'

vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.wo.foldminlines = 1
