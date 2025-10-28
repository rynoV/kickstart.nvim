-- autopairs
-- https://github.com/windwp/nvim-autopairs

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  opts = {
    fast_wrap = {},
    ignored_next_char = '[%w%.]', -- will ignore alphanumeric and `.` symbol
  },
  config = function(_, plugin_opts)
    local npairs = require 'nvim-autopairs'
    npairs.setup(plugin_opts)
    local Rule = require 'nvim-autopairs.rule'
    local cond = require 'nvim-autopairs.conds'
    -- For [||] and {||}
    npairs.add_rule(Rule('|', '|', { 'fsharp' }):with_pair(cond.before_regex '[%[%{]'):with_pair(cond.after_regex '[%]%}]'))
    npairs.get_rules("'")[1]:with_pair(function(opts)
      local bufnr = opts.bufnr or 0
      local filetype = vim.api.nvim_get_option_value('filetype', { buf = bufnr })
      -- Hacking to make generics ('T) easier to type. We check the parent
      -- nodes for the <> containers, and handle the case of an empty <> (the
      -- treesitter parser errors out when its empty)
      if filetype == 'fsharp' then
        vim.treesitter.get_parser(bufnr):parse()
        local target = vim.treesitter.get_node { bufnr = bufnr, ignore_injections = false }
        for _ = 0, 10 do
          if target == nil then
            break
          end

          if target:type() == 'types' or target:type() == 'type_arguments' or target:type() == 'typed_pattern' or target:type() == 'argument_patterns' then
            return false
          end

          target = target:parent()
        end

        return cond.not_before_regex '%<'(opts)
      end

      return true
    end)
  end,
}
