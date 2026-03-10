-- TODO: CTRL+G is very useful! it sets or unsets the fixed word (grep vs grep_word) so you can
-- have one fixed query and then use a second query (similar to my ripgrep + fzf finder).
-- But I want to understand what it does and how it works (it seems it swaps both queries, but
-- also an icon appears/disappears).
local picker_actions = {
  list_down_many = function(picker)
    picker.list:move(6)
  end,
  list_up_many = function(picker)
    picker.list:move(-6)
  end,
}

-- TODO: the only bad thing about this is that in the explorer, I usually use ctrl+d and ctrl+u
-- to scroll on the files (list), but in this case it scrolls the preview, however the preview isn't
-- enabled by default initially, so the keymaps do nothing when the preview isn't visible.
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

-- NOTE: This is a workaround to prevent session plugins from saving Snacks widgets.
-- Occasionally, the window to close might be the last one, which would cause it to fail.
-- However, encountering zombie widgets is quite rare. This can occur by opening an explorer
-- and executing :qa!
local function close_zombie_snacks()
  vim.schedule(function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      local filetype = vim.bo[buf].filetype

      if filetype:match "^snacks_" then
        require "notify" "Closing zombie Snacks widget"
        vim.api.nvim_win_close(win, false)
      end
    end
  end)
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    indent = {
      enabled = true,
      animate = { enabled = false },
      filter = function(buf)
        if vim.bo[buf].filetype == "markdown" then
          return false
        end

        return vim.g.snacks_indent ~= false and vim.b[buf].snacks_indent ~= false and vim.bo[buf].buftype == ""
      end,
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
      },
      win = {
        input = { keys = picker_keys },
        list = { keys = picker_keys },
      },
    },
  },

  config = function(_, opts)
    -- NOTE: Be aware that it may be necessary to wrap it in vim.schedule due to the order of plugin initialization.
    close_zombie_snacks()
    require("snacks").setup(opts)
  end,
}
