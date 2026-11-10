-- From https://github.com/actions/languageservices/tree/main/languageserver#in-neovim

-- Runs a command without blocking the UI. `cb` receives trimmed stdout, or nil on failure
local function run(cmd, opts, cb)
  vim.system(cmd, vim.tbl_extend('force', { text = true }, opts or {}), function(out)
    local stdout = out.code == 0 and vim.trim(out.stdout or '') or ''
    cb(stdout ~= '' and stdout or nil)
  end)
end

local function parse_github_remote(url)
  if not url or url == '' then
    return nil
  end

  -- Handles git@github.com:owner/repo.git and https://github.com/owner/repo.git
  local owner, repo = url:match 'github%.com[:/]([^/]+)/([^/]+)$'
  if not owner then
    return nil
  end
  return owner, (repo:gsub('%.git$', ''))
end

local function get_repo_info(owner, repo, cb)
  run({ 'gh', 'repo', 'view', owner .. '/' .. repo, '--json', 'id,owner', '--template', '{{.id}}\t{{.owner.type}}' }, nil, function(result)
    local id, owner_type = (result or ''):match '^(%d+)\t(.+)$'
    if id then
      cb { id = tonumber(id), organizationOwned = owner_type == 'Organization' }
    else
      cb(nil)
    end
  end)
end

-- Gathers the GitHub token and repo context for `root`, then calls `cb` with the
-- initialization options. Everything runs asynchronously so opening a file doesn't block
local function get_init_options(root, cb)
  run({ 'gh', 'auth', 'token' }, nil, function(token)
    run({ 'git', 'remote', 'get-url', 'origin' }, { cwd = root }, function(remote_url)
      local owner, name = parse_github_remote(remote_url)
      if not owner or not name then
        return cb { sessionToken = token }
      end
      get_repo_info(owner, name, function(info)
        cb {
          sessionToken = token,
          repos = {
            {
              id = info and info.id or 0,
              owner = owner,
              name = name,
              organizationOwned = info and info.organizationOwned or false,
              workspaceUri = 'file://' .. root,
            },
          },
        }
      end)
    end)
  end)
end

-- Init options are fetched once per root and cached. Pending requests wait for the same lookup
local cache = {}

local function resolve_root(bufnr, on_dir)
  local root = vim.fs.root(vim.api.nvim_buf_get_name(bufnr), { '.git' })
  if not root then
    return
  end

  local entry = cache[root]
  if entry and entry.options then
    return on_dir(root)
  end
  if entry then
    table.insert(entry.waiters, on_dir)
    return
  end

  entry = { waiters = { on_dir } }
  cache[root] = entry
  get_init_options(root, function(options)
    entry.options = options
    for _, waiter in ipairs(entry.waiters) do
      vim.schedule(function()
        waiter(root)
      end)
    end
    entry.waiters = {}
  end)
end

-- :MasonInstall gh-actions-language-server
return {
  cmd = { 'actions-languageserver', '--stdio' },
  filetypes = { 'yaml.ghactions' },
  root_dir = resolve_root,
  before_init = function(params)
    local entry = cache[params.rootPath or '']
    params.initializationOptions = entry and entry.options or {}
  end,
}
