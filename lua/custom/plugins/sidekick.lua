--- @type LazyPluginSpec
return {
  'folke/sidekick.nvim',
  dependencies = { 'folke/snacks.nvim' },
  opts = function()
    Snacks.toggle
      .new({
        name = 'NES',
        get = function()
          return require('sidekick.nes').enabled
        end,
        set = function(v)
          require('sidekick.nes').enable(v)
        end,
      })
      :map '<leader>tn'
    return {
      cli = {
        nes = {
          trigger = { events = {} },
        },
        win = {
          split = {
            width = 85,
            height = 20,
          },
        },
      },
    }
  end,
  keys = {
    {
      '<tab>',
      function()
        -- if there is a next edit, jump to it, otherwise apply it if any
        if not require('sidekick').nes_jump_or_apply() then
          return '<Tab>' -- fallback to normal tab
        end
      end,
      expr = true,
      desc = 'Goto/Apply Next Edit Suggestion',
    },
    {
      '<c-.>',
      function()
        require('sidekick.cli').focus()
      end,
      mode = { 'n', 'x', 'i', 't' },
      desc = 'Sidekick Switch Focus',
    },
    {
      '<m-/>',
      function()
        require('sidekick.nes').update()
      end,
      desc = 'Suggest Next Edit',
      mode = { 'n', 'v' },
    },
    {
      '<leader>aa',
      function()
        require('sidekick.cli').toggle { name = 'copilot', focus = true }
      end,
      desc = 'Sidekick Copilot Toggle',
      mode = { 'n', 'v' },
    },
    {
      '<leader>at',
      function()
        require('sidekick.cli').send { msg = '{this}' }
      end,
      mode = { 'x', 'n' },
      desc = 'Send This',
    },
    {
      '<leader>as',
      function()
        require('sidekick.cli').send { selection = true }
      end,
      mode = { 'v' },
      desc = 'Sidekick Send Visual Selection',
    },
    {
      '<leader>ap',
      function()
        require('sidekick.cli').prompt()
      end,
      mode = { 'n', 'x' },
      desc = 'Sidekick Select Prompt',
    },
  },
}
