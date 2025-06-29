local has_toggleterm, toggleterm = pcall(require, "toggleterm")

if not has_toggleterm then
  error(" gradlew-tasks.nvim requires toggleterm.nvim -https://github.com/akinsho/toggleterm.nvim")
end

local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local config = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

M.setup = function()
  -- nothing
end

local get_tasks = function(opts)
  opts = opts or {}
  opts.entry_maker = function(entry)
    local task, description = string.match(entry, "(%w+:*%w*) %- (.*)$")
    if task ~= nil then
      description = description or " "
      return {
        display = "🐘" .. task .. " ℹ:" .. description,
        value = { task = task, description = description },
        ordinal = entry,
      }
    end
    return nil
  end
  pickers
    .new(opts, {
      prompt_title = "Gradle Tasks",
      finder = finders.new_oneshot_job({
        "sh",
        "gradlew",
        "tasks",
        "--all",
      }, opts),
      sorter = config.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          --print(vim.inspect(selection))
          --vim.api.nvim_command(":terminal ./gradlew " .. selection.value.task)
          toggleterm.exec(
            "./gradlew " .. selection.value.task,
            1,
            nil,
            nil,
            "float",
            "Running: " .. selection.value.task,
            true,
            true
          )
        end)
        return true
      end,
    })
    :find()
end

M.get_tasks = get_tasks
return M
