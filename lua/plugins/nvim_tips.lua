return {
  'saxon1964/neovim-tips',
  version = '*', -- Only update on tagged releases
  event = 'VeryLazy',
  dependencies = {
    'MunifTanjim/nui.nvim',
    -- OPTIONAL: Choose your preferred markdown renderer (or omit for raw markdown)
    'MeanderingProgrammer/render-markdown.nvim', -- Clean rendering
    -- OR: "OXY2DEV/markview.nvim", -- Rich rendering with advanced features
  },
  opts = {},
}
