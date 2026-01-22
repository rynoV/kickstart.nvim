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
    --- @type sidekick.Config
    local conf = {
      cli = {
        nes = {
          enabled = true,
          trigger = { events = {} },
        },
        win = {
          split = {
            width = 85,
            height = 20,
          },
        },
        tools = {
          copilot = { cmd = { 'copilot' } },
        },
      },
    }
    return conf
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
        require('sidekick.cli').toggle()
      end,
      mode = { 'n', 'x', 'i', 't' },
      desc = 'Sidekick Toggle',
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
      '<leader>af',
      function()
        require('sidekick.cli').send { msg = '{file}' }
      end,
      desc = 'Send File',
    },
    {
      '<leader>av',
      function()
        require('sidekick.cli').send { msg = '{selection}' }
      end,
      mode = { 'x' },
      desc = 'Send Visual Selection',
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
