local utils = require("react-native-directory.utils")
local Job = require("plenary.job")
require("react-native-directory.store")

---@class FetchDataOpts
---@field query? string
---@field keywords? string[]
---@field callback? fun(): nil

local M = {}

---@param store RndStore
---@param opts FetchDataOpts?
function M.fetch_data(store, opts)
  local base_api_url = "https://reactnative.directory/api/libraries"
  local url = base_api_url

  if opts ~= nil then
    local hasQuery = not utils.is_white_space(opts.query)
    if hasQuery then
      url = url .. "?search=" .. vim.uri_encode(opts.query)
    end

    if opts.keywords ~= nil and #opts.keywords > 0 then
      if not hasQuery then
        url = url .. "?"
      end

      for index, value in pairs(opts.keywords) do
        if index > 1 or hasQuery then
          url = url .. "&"
        end
        url = url .. value .. "=true"
      end
    end
  end

  store.logger:log("network request start", url)

  Job:new({
    command = "curl",
    args = { "-s", "-H", "Accept: application/json", url },
    on_exit = function(j, code)
      store.logger:log("network request end", url, code)
      if code == 0 then
        local json_str = table.concat(j:result())
        local ok, result = pcall(vim.json.decode, json_str)
        if ok and result then
          store.library = result.libraries
          vim.defer_fn(function()
            if opts ~= nil and opts.callback ~= nil then
              opts.callback()
            end
          end, 0)
        else
          store.logger:log("Failed to parse JSON", url, result, json_str)
          vim.notify("Failed to parse JSON " .. result, vim.logs.level.ERROR)
        end
      else
        store.logger:log("Curl exited with code", url, code)
        vim.notify("Curl exited with code " .. code, vim.logs.level.ERROR)
      end
    end,
  }):start()
end

return M
