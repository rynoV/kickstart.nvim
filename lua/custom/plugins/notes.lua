local haunt_prefix = '<leader>n'

--- @type LazySpec
return {
  haunt_prefix = haunt_prefix,
  'TheNoeTrevino/haunt.nvim',
  dependencies = { 'ghostbuster91/nvim-next' },
  keys = {
    {
      haunt_prefix .. 'a',
      function()
        require('haunt.api').annotate()
      end,
      desc = 'Annotate',
    },
    {
      haunt_prefix .. 't',
      function()
        require('haunt.api').toggle_annotation()
      end,
      desc = 'Toggle annotation',
    },
    {
      haunt_prefix .. 'T',
      function()
        require('haunt.api').toggle_all_lines()
      end,
      desc = 'Toggle all annotations',
    },
    {
      haunt_prefix .. 'd',
      function()
        require('haunt.api').delete()
      end,
      desc = 'Delete bookmark',
    },
    {
      haunt_prefix .. 'C',
      function()
        require('haunt.api').clear_all()
      end,
      desc = 'Delete all bookmarks',
    },
    {
      haunt_prefix .. 'p',
      function()
        require('haunt.api').prev()
      end,
      desc = 'Previous bookmark',
    },
    {
      haunt_prefix .. 'n',
      function()
        require('haunt.api').next()
      end,
      desc = 'Next bookmark',
    },
    {
      haunt_prefix .. 'l',
      function()
        require('haunt.picker').show()
      end,
      desc = 'Show Picker',
    },
    {
      haunt_prefix .. 'q',
      function()
        require('haunt.api').to_quickfix()
      end,
      desc = 'Send Hauntings to QF List (buffer)',
    },
    {
      haunt_prefix .. 'Q',
      function()
        require('haunt.api').to_quickfix { current_buffer = true }
      end,
      desc = 'Send Hauntings to QF List (all)',
    },
    {
      haunt_prefix .. 'y',
      function()
        require('haunt.api').yank_locations { current_buffer = true }
      end,
      desc = 'Send Hauntings to Clipboard (buffer)',
    },
    {
      haunt_prefix .. 'Y',
      function()
        require('haunt.api').yank_locations()
      end,
      desc = 'Send Hauntings to Clipboard (all)',
    },
  },
}
