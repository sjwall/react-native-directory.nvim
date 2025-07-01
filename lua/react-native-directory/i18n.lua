local Path = require("plenary.path")
local json = require("plenary.json")

---@class I18n
---@field locale_dir string
---@field locale string
---@field translations {string: {string: string}}
local I18n = {}
I18n.__index = I18n

local function get_script_dir()
  local info = debug.getinfo(1, "S")
  local script_path = info.source:sub(2)
  return Path:new(script_path):parent()
end

---Create a new I18n instance
---@param opts table? with fields:
--   - locale_dir: string, path to the directory containing JSON files
--   - locale: string, desired locale code (e.g. "fr")
function I18n:new(opts)
  opts = opts or {}
  local obj = setmetatable({}, self)

  local install_dir = get_script_dir()
  obj.locale_dir = opts.locale_dir or (install_dir / "locales")
  obj.locale = opts.locale or "en"

  obj.translations = {
    en = {},
    [obj.locale] = {},
  }

  obj:_load_locale("en")
  if obj.locale ~= "en" then
    obj:_load_locale(obj.locale)
  end

  return obj
end

function I18n:_load_locale(locale)
  local locale_path = Path:new(self.locale_dir, locale .. ".json")
  if not locale_path:exists() then
    vim.notify("i18n: locale file not found: " .. locale_path:absolute(), vim.log.levels.WARN)
    return
  end

  local content = locale_path:read()
  local ok, result = pcall(vim.json.decode, content)
  if ok and result then
    self.translations[locale] = result
  else
    vim.notify("i18n: failed to decode JSON for locale: " .. locale, vim.log.levels.ERROR)
  end
end

local function get_nested(tbl, parts)
  for _, part in ipairs(parts) do
    tbl = tbl[part]
    if tbl == nil then
      return nil
    end
  end
  return tbl
end

---Get a localized string
---@param key string, key to lookup (e.g., "greeting.hello")
---@param vars table?: optional table of variables to interpolate (e.g., { name = "Alice" })
---@return string
function I18n:translate(key, vars)
  local parts = vim.split(key, ".", { plain = true })

  local value = get_nested(self.translations[self.locale], parts)
  if value == nil then
    value = get_nested(self.translations["en"], parts)
  end

  value = value or key

  if type(value) == "string" and vars and type(vars) == "table" then
    value = value:gsub("{{(.-)}}", function(var)
      return vars[var] or ("{{" .. var .. "}}")
    end)
  end

  return value
end

return I18n
