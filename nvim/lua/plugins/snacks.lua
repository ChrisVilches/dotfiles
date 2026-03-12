local picker_actions = {
  list_down_many = function(picker)
    picker.list:move(6)
  end,
  list_up_many = function(picker)
    picker.list:move(-6)
  end,
}

local picker_keys = {
  ["<c-f>"] = { "toggle_maximize", mode = { "i", "n" } },
  ["<c-c>"] = { "cancel", mode = { "i", "n" } },
  ["<c-j>"] = { "list_down_many", mode = { "i", "n" } },
  ["<c-k>"] = { "list_up_many", mode = { "i", "n" } },
  ["<c-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
  ["<c-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
}

local function explorer_configure_auto_close(picker)
  local wins = picker.layout.wins

  picker.layout.root:on("WinLeave", function()
    vim.schedule(function()
      local next_win = vim.api.nvim_get_current_win()

      -- Windows inside the explorer that are whitelisted and don't close the explorer when focused.
      for _, w in ipairs { wins.input.win, wins.list.win, wins.preview.win } do
        if next_win == w then
          return
        end
      end

      picker:close()
    end)
  end)
end

local function indent_filter(buf)
  if vim.bo[buf].filetype == "markdown" then
    return false
  end

  return vim.g.snacks_indent ~= false and vim.b[buf].snacks_indent ~= false and vim.bo[buf].buftype == ""
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    indent = {
      enabled = true,
      animate = { enabled = false },
      filter = indent_filter,
    },
    input = { enabled = true },
    picker = {
      actions = picker_actions,
      enabled = true,
      layout = { preset = "ivy" },
      sources = {
        explorer = {
          win = {
            list = { keys = picker_keys },
          },
          on_show = function(picker)
            explorer_configure_auto_close(picker)
          end,
        },
        grep = { hidden = true },
        grep_word = { hidden = true },
      },
      win = {
        input = { keys = picker_keys },
        list = { keys = picker_keys },
      },
    },
  },
}
