local M = {}

local tab_types = { 'source', 'diff', 'emacs', 'terminal' }

local function regular_windows(tabpage)
  return vim.tbl_filter(function(win)
    return vim.api.nvim_win_get_config(win).relative == ''
  end, vim.api.nvim_tabpage_list_wins(tabpage))
end

local function buffer_is_terminal(buf)
  return vim.api.nvim_get_option_value('buftype', { buf = buf }) == 'terminal'
    -- We use this to filter out buffers that only have terminal
    -- highlighting from `vim.api.nvim_open_term`
    and vim.startswith(vim.api.nvim_buf_get_name(buf), 'term://')
end

local function terminal_command(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  return name:match '^term://.-//%d+:(.*)$'
end

local function terminal_job_is_running(buf)
  local channel = vim.bo[buf].channel
  return channel > 0 and vim.fn.jobwait({ channel }, 0)[1] == -1
end

local function buffer_is_emacs(buf)
  if not buffer_is_terminal(buf) or not terminal_job_is_running(buf) then
    return false
  end

  local command = terminal_command(buf)
  local executable = command and command:match '^%s*([^%s]+)'
  return executable ~= nil and vim.fs.basename(executable:gsub('^[\'"]', ''):gsub('[\'"]$', '')) == 'emacsclient'
end

local function source_window(tabpage)
  local cwd = vim.fs.normalize(vim.fs.abspath '.')

  for _, win in ipairs(regular_windows(tabpage)) do
    local path = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
    if path ~= '' then
      path = vim.fs.normalize(vim.fs.abspath(path))
      local stat = vim.uv.fs_stat(path)
      if stat and stat.type == 'file' and (path == cwd or vim.startswith(path, cwd .. '/')) then
        return win
      end
    end
  end
end

local function is_diff(tabpage)
  local diff_windows = vim.tbl_filter(function(win)
    return vim.api.nvim_get_option_value('diff', { win = win })
  end, regular_windows(tabpage))
  return #diff_windows >= 2
end

local predicates = {
  source = function(tabpage)
    return not is_diff(tabpage) and source_window(tabpage) ~= nil
  end,
  diff = is_diff,
  emacs = function(tabpage)
    local wins = regular_windows(tabpage)
    return #wins == 1 and buffer_is_emacs(vim.api.nvim_win_get_buf(wins[1]))
  end,
  terminal = function(tabpage)
    local wins = regular_windows(tabpage)
    return #wins == 1 and buffer_is_terminal(vim.api.nvim_win_get_buf(wins[1])) and not buffer_is_emacs(vim.api.nvim_win_get_buf(wins[1]))
  end,
}

predicates.other = function(tabpage)
  for _, kind in ipairs(tab_types) do
    if predicates[kind](tabpage) then
      return false
    end
  end
  return true
end

---@param kind 'source'|'diff'|'terminal'|'emacs'|'other'
---@param opts? { exclude?: integer }
---@return integer? tabpage
---@return integer? window
function M.find(kind, opts)
  local predicate = predicates[kind]
  assert(predicate, 'Unknown tab type: ' .. tostring(kind))

  for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    if not opts or tabpage ~= opts.exclude then
      if predicate(tabpage) then
        if kind == 'source' then
          return tabpage, source_window(tabpage)
        end
        return tabpage
      end
    end
  end
end

function M.is_source(tabpage)
  return predicates.source(tabpage or 0)
end

function M.is_diff(tabpage)
  return predicates.diff(tabpage or 0)
end

function M.is_terminal(tabpage)
  return predicates.terminal(tabpage or 0)
end

function M.is_emacs(tabpage)
  return predicates.emacs(tabpage or 0)
end

function M.is_other(tabpage)
  return predicates.other(tabpage or 0)
end

---@param kind 'source'|'diff'|'terminal'|'emacs'|'other'
---@param opts? { exclude?: integer }
---@return integer? tabpage
function M.select(kind, opts)
  local tabpage = M.find(kind, opts)
  if tabpage then
    vim.api.nvim_set_current_tabpage(tabpage)
  end
  return tabpage
end

function M.new_terminal()
  if M.is_terminal() then
    vim.cmd 'term'
    return
  end

  if not M.select 'terminal' then
    vim.cmd 'tab term'
  end
end

function M.new_emacs()
  if M.is_emacs() then
    return
  end

  if not M.select 'emacs' then
    vim.cmd 'tab term emacsclient -a \'\' -c -nw -F "((calum-nvim . \\"$NVIM\\") (calum-magit-mode . t))" --eval "(magit-status)"'
  end
end

---@param kind 'source'|'diff'|'other'
function M.open(kind)
  assert(kind == 'source' or kind == 'diff' or kind == 'other', 'Invalid non-terminal tab type: ' .. tostring(kind))
  if not M.select(kind) then
    vim.cmd 'tabnew'
  end
end

function M.open_for_file(path, is_diff)
  if is_diff then
    vim.cmd 'tabnew'
    return
  end

  local absolute_path = vim.fs.normalize(vim.fs.abspath(path or ''))
  local cwd = vim.fs.normalize(vim.fs.abspath '.')
  local stat = vim.uv.fs_stat(absolute_path)
  local is_cwd_file = stat
    and stat.type == 'file'
    and (absolute_path == cwd or vim.startswith(absolute_path, cwd .. '/'))

  M.open(is_cwd_file and 'source' or 'other')
end

return M
