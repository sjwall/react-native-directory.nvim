local library = require("react-native-directory.library")

local M = {}

---@param str string
---@return string
---@return integer count
function M.trim(str)
  return str:gsub("^%s+", ""):gsub("%s+$", "")
end

---@param str string
---@return string
---@return integer count
function M.remove_duplicate_whitespace(str)
  return str:gsub("%s+", " ")
end

---@param str string
---@param sep string
---@return string[]
function M.split(str, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for s in string.gmatch(str, "([^" .. sep .. "]+)") do
    table.insert(t, s)
  end
  return t
end

---@param str string?
---@return boolean
function M.is_white_space(str)
  return str == nil or str:gsub("%s", "") == ""
end

---@param item RndLibraryItem
---@return string
function M.getSupportedPlatforms(item)
  local result = {}

  for _, key in ipairs(library.platforms) do
    if item[key] then
      table.insert(result, key)
    end
  end

  return table.concat(result, ", ")
end

return M
