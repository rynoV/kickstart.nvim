local labels = 'aoeuhtnsidqjkmwv,.pgcr'
local full_labels = labels .. ";z'l!@#$%^&*(){}|_+:"

---@type LazyPluginSpec
return {
  'folke/flash.nvim',
  opts = function()
    function flash_diagnostic()
      require('flash').jump {
        matcher = function(win)
          ---@param diag Diagnostic
          return vim.tbl_map(function(diag)
            return {
              pos = { diag.lnum + 1, diag.col },
              end_pos = { diag.end_lnum + 1, diag.end_col - 1 },
            }
          end, vim.diagnostic.get(vim.api.nvim_win_get_buf(win)))
        end,
        action = function(match, state)
          vim.api.nvim_win_call(match.win, function()
            vim.api.nvim_win_set_cursor(match.win, match.pos)
            vim.diagnostic.open_float()
          end)
          state:restore()
        end,
      }
    end
    ---@type Flash.Config
    local opts = {
      labels = labels,
      modes = {
        char = { enabled = false },
        treesitter = {
          labels = labels,
          label = {
            style = 'overlay',
          },
        },
      },
      label = {
        style = 'overlay',
        uppercase = false,
        rainbow = {
          enabled = false,
        },
      },
    }
    return opts
  end,
  -- stylua: ignore
  keys = {
    -- A lot of the power here comes from using these shortcuts in operator
    -- pending mode. For example using them after y, c, d, etc. This also
    -- allows for dot-repeating these actions.
    -- In operator pending mode I have these set to work as "remote" operations
    -- so they restore the cursor after performing the action, which is useful
    -- for yanking.
    { "s", mode = { "n", "x" }, function() require("flash").jump() end, desc = "Flash" },
    { "s", mode = { "o" }, function() require("flash").jump({remote_op = {restore = true, motion = true}}) end, desc = "Flash" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "R", mode = { "o" }, function() require("flash").treesitter_search({remote_op = {restore = true, motion = true}}) end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    { "<a-d>", function () flash_diagnostic() end, desc = "Show diagnostic" },
    { "<esc>", mode = "n", function ()
      vim.cmd("nohlsearch")
      local char = require("flash.plugins.char")
      if char.state then
        char.state:hide()
      end
    end, desc = "Clear search highlights" },
    { "<c-space>", mode = {"n", "x", "o"}, function()
      require("flash").treesitter({
        actions = {
          -- Note that ; and , also work
          ["<c-space>"] = "next",
          ["<BS>"] = "prev"
        },
        -- Don't show any labels since treesitter jump by label is covered
        -- above, and these two actions can be used together
        labels = "",
      })
    end, { desc = "Treesitter incremental selection" }}
  },
  specs = {
    {
      'folke/snacks.nvim',
      opts = {
        picker = {
          win = {
            input = {
              keys = {
                ['<a-s>'] = { 'flash', mode = { 'n', 'i' } },
                ['s'] = { 'flash' },
              },
            },
          },
          actions = {
            flash = function(picker)
              require('flash').jump {
                pattern = '^',
                labels = (full_labels .. full_labels:upper()):reverse(),
                label = { after = { 0, 0 } },
                search = {
                  mode = 'search',
                  exclude = {
                    function(win)
                      return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= 'snacks_picker_list'
                    end,
                  },
                },
                action = function(match)
                  local idx = picker.list:row2idx(match.pos[1])
                  picker.list:_move(idx, true, true)
                end,
              }
            end,
          },
        },
      },
    },
  },
}
