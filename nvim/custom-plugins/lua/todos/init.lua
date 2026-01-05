local M = {}

local function get_todos()
  local rg_glob_flags = {
    "--glob",
    "!package-lock.json",
    "--glob",
    "!tmp",
    "--glob",
    "!log",
  }

  local rg_flags = {
    "--line-number",
    "--no-heading",
    "--color=always",
  }

  local todo_pattern = "T" .. "O" .. "D" .. "O" .. ":"
  local cmd = vim.list_extend({ "rg" }, rg_flags)
  cmd = vim.list_extend(cmd, rg_glob_flags)
  local pattern = "'(^-\\s+\\[\\s*\\])|(" .. todo_pattern .. ")'"
  table.insert(cmd, pattern)

  local cmd_str = table.concat(cmd, " ")
  local handle = io.popen(cmd_str)
  if not handle then
    vim.notify("Failed to run rg command", vim.log.levels.ERROR)
    return {}
  end

  local result = handle:read "*a"
  handle:close()

  local entries = {}
  for line in result:gmatch "[^\r\n]+" do
    -- Remove ANSI color codes
    local clean_line = line:gsub("\27%[[%d;]*m", "")
    local file, line_num, content = clean_line:match "^([^:]+):(%d+):(.+)$"
    if file and line_num and content then
      table.insert(entries, {
        filename = file,
        lnum = tonumber(line_num),
        col = 1,
        text = content,
      })
    end
  end

  return entries
end

function M.show_todos()
  local entries = get_todos()

  if #entries == 0 then
    vim.notify("No TODOs found", vim.log.levels.INFO)
    return
  end

  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local conf = require("telescope.config").values
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"

  pickers
    .new({}, {
      prompt_title = "TODOs",
      finder = finders.new_table {
        results = entries,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.filename .. ":" .. entry.lnum .. ": " .. entry.text,
            ordinal = entry.filename .. " " .. entry.text,
            filename = entry.filename,
            lnum = entry.lnum,
            col = entry.col,
          }
        end,
      },
      sorter = conf.generic_sorter {},
      previewer = conf.grep_previewer {},
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            vim.cmd("edit " .. vim.fn.fnameescape(selection.filename))
            vim.api.nvim_win_set_cursor(0, { selection.lnum, selection.col - 1 })
          end
        end)
        return true
      end,
    })
    :find()
end

return M
