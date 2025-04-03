local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
---@diagnostic disable-next-line: inject-field
parser_config.surrealql = {
  install_info = {
    url = 'https://github.com/Ce11an/tree-sitter-surrealql',
    files = { 'src/parser.c' },
    branch = 'main',
  },
  filetype = 'surql',
  maintainers = { '@Ce11an' },
}
