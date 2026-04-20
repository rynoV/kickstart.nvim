---@type LazySpec
return {
  'gbprod/nord.nvim',
  priority = 1000, -- Make sure to load this before all the other start plugins.
  init = function()
    require('nord').setup {
      transparent = true,
      on_highlights = function(highlights, colors)
        -- The default highlighting for diffs overrides the foreground syntax
        -- highlighting. This changes it to an approach more like tokyo-night
        -- which marks the diff regions using only the background colors
        highlights.DiffAdd = { bg = colors.polar_night.bright }
        -- Deleted text is just the deletion markers and not any content, so
        -- we set the foreground
        highlights.DiffDelete = { fg = colors.aurora.red }
        -- DiffText sits on top of DiffChange, so it should stand out
        highlights.DiffChange = { bg = colors.polar_night.bright }
        highlights.DiffText = { bg = colors.polar_night.brightest }
        highlights.FloatBorder = { fg = colors.frost.artic_ocean }
      end,
    }
    vim.cmd.colorscheme 'nord'
  end,
}
