local M = {}

M.tokens = {
  android = "android",
  expogo = "expoGo",
  go = "expoGo",
  ios = "ios",
  macos = "macos",
  fireos = "fireos",
  tvos = "tvos",
  visionos = "visionos",
  web = "web",
  windows = "windows",
  hasexample = "hasExample",
  hasimage = "hasImage",
  hastypes = "hasTypes",
  ismaintained = "isMaintained",
  ispopular = "isPopular",
  wasrecentlyupdated = "wasRecentlyUpdated",
  newarchitecture = "newArchitecture",
}

---@param prompt string
function M:process_prompt(prompt)
  local keywords = {}
  local query = prompt:gsub(":%S+", function(match)
    local keyword = match:sub(2):lower()
    for key, value in pairs(self.tokens) do
      if type(key) == "string" then
        if string.sub(key, 1, #keyword) == keyword then
          table.insert(keywords, value)
        end
      end
    end
    return ""
  end)

  query = query:gsub("  ", " "):gsub("^%s*(.-)%s*$", "%1")
  return { query = query, keywords = keywords }
end

return M
