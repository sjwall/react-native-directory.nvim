local has_telescope, _ = pcall(require, "telescope")

if not has_telescope then
  error("react-native-directory.nvim requires nvim-telescope/telescope.nvim")
end

local rnd = require("react-native-directory")
local rndUtils = require("react-native-directory.utils")
local tokens = require("react-native-directory.tokens")
local actions = require("telescope.actions")
local action_set = require("telescope.actions.set")
local action_state = require("telescope.actions.state")
local debounce = require("telescope.debounce")
local previewers = require("telescope.previewers")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")

---@class Entry
---@field value RndLibraryItem
---@field display string
---@field ordinal string

local run = function(opts)
  local previousPrompt = nil
  local previous_parsed = nil
  local previous_keywords = nil
  local picker
  local data_debounce = debounce.debounce_trailing(function(prompt)
    local prompt_trimmed = rndUtils.trim(prompt or "")
    if prompt_trimmed ~= previousPrompt then
      previousPrompt = prompt_trimmed

      local result = tokens:process_prompt(prompt_trimmed)

      if previous_parsed ~= result.query or #result.keywords ~= #previous_keywords then
        previous_parsed = result.query
        previous_keywords = result.keywords
        rnd:search({
          query = result.query,
          keywords = result.keywords,
          callback = function()
            picker:refresh()
          end,
        })
      end
    end
  end, 1000)
  picker = pickers.new(opts, {
    prompt_title = rnd.i18n:translate("telescope.prompt_title"),
    finder = finders.new_dynamic({
      fn = function(prompt)
        data_debounce(prompt)
        return rnd.library or {}
      end,
      ---@param entry RndLibraryItem
      ---@return Entry
      entry_maker = function(entry)
        local name = entry.npmPkg
        if name == nil then
          name = entry.github.fullName
        end
        return {
          value = entry,
          display = name,
          ordinal = name,
        }
      end,
    }),
    previewer = previewers.new_buffer_previewer({
      title = rnd.i18n:translate("telescope.preview_title"),
      dyn_title = function(_, entry)
        return entry.display
      end,
      get_buffer_by_name = function(_, entry)
        return "rnd_" .. entry.display
      end,
      ---@param entry Entry
      define_preview = function(self, entry, status)
        if self.state.bufname then
          return
        end
        local unmaintained = ""
        if entry.value.unmaintained == false then
          unmaintained = rnd.i18n:translate("telescope.unmaintained")
        end
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, {
          entry.display,
          unmaintained,
          entry.value.github.description,
          entry.value.githubUrl,
          "",
          rnd.i18n:translate("telescope.platforms", { platforms = rndUtils.getSupportedPlatforms(entry.value) }),
        })
      end,
    }),
    attach_mappings = function(_, map)
      action_set.select:replace(function(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.ui.open(entry.value.githubUrl)
      end)

      map({ "i", "n" }, "<C-i>", function(prompt_bufnr)
        ---@type Entry
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        rnd:install({
          package = entry.value.npmPkg,
          dev = entry.value.dev or false,
        })
      end)
      return true
    end,
  })
  picker:find()
end

return require("telescope").register_extension({
  exports = {
    rnd = run,
  },
})
