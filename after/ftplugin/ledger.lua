vim.api.nvim_create_user_command('LedgerSort', function(opts)
  local line1 = opts.line1
  local line2 = opts.line2

  -- Run the selected lines through hledger
  vim.cmd(string.format('%d,%d! hledger -f - -I print', line1, line2))

  local has_conform, conform = pcall(require, 'conform')
  if has_conform then
    conform.format()
  end
end, { range = true })
