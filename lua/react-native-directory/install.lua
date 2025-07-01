local Job = require("plenary.job")

local Install = {}

---Helper function to find a file by searching up the directory tree
local function find_up(store, start_path, filename)
  local path = vim.fn.fnamemodify(start_path, ":p")
  while path ~= "/" do
    store.logger:log("searching for ", filename, " in: ", path)
    local full_path = path .. "/" .. filename
    if vim.fn.filereadable(full_path) == 1 then
      return full_path
    end
    path = vim.fn.fnamemodify(path, ":h")
    return nil
  end
  return nil
end

local function get_package_manager(dir)
  if vim.fn.filereadable(dir .. "/yarn.lock") == 1 then
    return "yarn"
  elseif vim.fn.filereadable(dir .. "/package-lock.json") == 1 then
    return "npm"
  elseif vim.fn.filereadable(dir .. "/pnpm-lock.yaml") == 1 then
    return "pnpm"
  elseif vim.fn.filereadable(dir .. "/bun.lock") == 1 or vim.fn.filereadable(dir .. "/bun.lockb") == 1 then
    return "bun"
  end
  return nil
end

---@param path string
local function has_scheme(path)
  return path:find("^%w+://") ~= nil
end

---@class InstallOpts
---@field cwd string?
---@field package string
---@field dev boolean

---@param store RndStore
---@param opts InstallOpts
function Install.install(opts, store)
  local start_dir = opts.cwd

  if start_dir == nil then
    local current_file = vim.api.nvim_buf_get_name(0)
    if current_file and current_file ~= "" then
      start_dir = vim.fn.fnamemodify(current_file, ":h")
    else
      start_dir = vim.fn.getcwd()
    end
  end

  if has_scheme(start_dir) then
    if string.sub(start_dir, 1, 6) == "oil://" then
      start_dir = string.sub(start_dir, 7)
    else
      start_dir = vim.fn.getcwd()
    end
  end

  local package_json_path = find_up(store, start_dir, "package.json")
  if not package_json_path then
    vim.notify("RND: No package.json found in the current directory or its ancestors.", vim.log.levels.ERROR)
    return
  end

  local package_json_dir = vim.fn.fnamemodify(package_json_path, ":h")
  store.logger:log("found " .. package_json_path)

  local package_manager = nil
  local search_dir = package_json_dir

  while search_dir ~= "/" do
    package_manager = get_package_manager(search_dir)
    if package_manager then
      break
    end
    search_dir = vim.fn.fnamemodify(search_dir, ":h") -- Go up
  end

  if not package_manager then
    vim.notify(
      "RND: No lock file (yarn.lock, package-lock.json, pnpm-lock.yaml, bun.lock, bun.lockb) found for any package manager in the package.json directory or its ancestors.",
      vim.log.levels.ERROR
    )
    return
  end

  store.logger:log("found " .. package_manager)

  local install_args = {}
  if package_manager == "yarn" or package_manager == "pnpm" or package_manager == "bun" then
    table.insert(install_args, "add")
  elseif package_manager == "npm" then
    table.insert(install_args, "install")
  else
    vim.notify("RND: Unsupported package manager detected.", vim.log.levels.ERROR)
    return
  end

  if opts.dev then
    table.insert(install_args, "-D")
  end

  table.insert(install_args, opts.package)

  local log = "RND Running: " .. package_manager .. vim.inspect(install_args) .. " in " .. package_json_dir
  store.logger:log(log)
  vim.notify(log, vim.log.levels.INFO)
  Job:new({
    command = package_manager,
    args = install_args,
    cwd = package_json_dir,
    on_exit = function(_, code)
      vim.defer_fn(function()
        if code == 0 then
          vim.notify("RND: install successful")
        else
          store.logger:log("Install exited with code", code)
          vim.notify("Install exited with code " .. code, vim.logs.level.ERROR)
        end
      end, 0)
    end,
  }):start()
end

return Install
