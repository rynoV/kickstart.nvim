vim.filetype.add {
  extension = {
    surql = 'surql',
    hledger = 'ledger',
  },
  pattern = {
    ['.*/%.github/workflows/.*%.ya?ml'] = 'yaml.ghactions',
  },
}
