local M = {}

local closed_buffers = {}

local function save_closed_buffer(filepath)
  for _, item in ipairs(closed_buffers) do
    if item == filepath then
      return
    end
  end
  table.insert(closed_buffers, filepath)
end

function M.listed_buffers()
  return vim.tbl_filter(function(buf)
    return vim.bo[buf].buflisted and vim.bo[buf].buftype == ""
  end, vim.api.nvim_list_bufs())
end

function M.listen_closed_buffers()
  vim.api.nvim_create_autocmd("BufDelete", {
    callback = function(ev)
      local name = vim.api.nvim_buf_get_name(ev.buf)
      local should_add_to_history = vim.bo[ev.buf].buflisted and vim.bo[ev.buf].buftype == "" and name ~= ""

      if should_add_to_history then
        save_closed_buffer(vim.fn.fnamemodify(name, ":."))
      end
    end,
  })
end

function M.reopen()
  if #closed_buffers == 0 then
    vim.notify("No closed buffers to reopen", vim.log.levels.WARN)
    return
  end

  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local conf = require("telescope.config").values
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"

  pickers
    .new({}, {
      prompt_title = "Closed Buffers",
      sorter = conf.generic_sorter {},
      finder = finders.new_table {
        results = vim.fn.reverse(vim.deepcopy(closed_buffers)),
        entry_maker = function(entry)
          return { value = entry, display = entry, ordinal = entry }
        end,
      },
      previewer = conf.file_previewer {},
      attach_mappings = function(_, map)
        map({ "i", "n" }, "<CR>", function(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if selection then
            vim.cmd("buffer " .. selection.value)
            vim.bo.buflisted = true
            for i, entry in ipairs(closed_buffers) do
              if entry == selection.value then
                table.remove(closed_buffers, i)
                break
              end
            end
          end
        end)
        return true
      end,
    })
    :find()
end

return M
