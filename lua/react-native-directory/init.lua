local Log = require("react-native-directory.logger")
local I18n = require("react-native-directory.i18n")
local Install = require("react-native-directory.install")
require("react-native-directory.store")

---@class Rnd : RndStore
---@field logger RndLog
---@field i18n I18n
local Rnd = {}

Rnd.__index = Rnd

---@return Rnd
function Rnd:new()
  local rnd = setmetatable({
    logger = Log,
    i18n = I18n:new(),
  }, self)

  return rnd
end

function Rnd.reload()
  require("plenary.reload").reload_module("react-native-directory")
end

---@param opts FetchDataOpts?
function Rnd:search(opts)
  require("react-native-directory.data").fetch_data(self, opts)
end

---@param opts InstallOpts
function Rnd:install(opts)
  Install.install(opts, self)
end

local the_rnd = Rnd:new()

---@param self Rnd
---@return Rnd
function Rnd.setup(self)
  if self ~= the_rnd then
    self = the_rnd
  end

  return self
end

return the_rnd
