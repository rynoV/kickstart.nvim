return {
  'ghostbuster91/nvim-next',
  opts = function()
    local nvim_next_builtins = require 'nvim-next.builtins'
    return {
      default_mappings = {
        repeat_style = 'original',
      },
      items = {
        nvim_next_builtins.f,
        nvim_next_builtins.t,
      },
    }
  end,
}
