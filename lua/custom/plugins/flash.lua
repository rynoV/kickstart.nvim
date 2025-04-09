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
          enabled = true,
        },
      },
    }
    return opts
  end,
  -- stylua: ignore
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "<a-r>", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    { "<a-d>", function () flash_diagnostic() end, desc = "Show diagnostic" },
    { "<esc>", mode = "n", function ()
      vim.cmd("nohlsearch")
      local char = require("flash.plugins.char")
      if char.state then
        char.state:hide()
      end
    end, desc = "Clear search highlights" }
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
