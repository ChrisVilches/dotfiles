local function move(n, key)
  return function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(n .. key, true, false, true), "n", false)
  end
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
  -- TODO: Experiment enabling more widgets.
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    -- bigfile = { enabled = true },
    -- dashboard = { enabled = true },
    explorer = {
      enabled = true,
      keys = {
        ["<C-j>"] = move(6, "j"),
        ["<C-k>"] = move(6, "k"),
      },
    },
    indent = {
      enabled = true, -- enable indent guides
      animate = {
        enabled = false,
      },
      filter = function(buf)
        if vim.bo[buf].filetype == "markdown" then
          return false
        end

        return vim.g.snacks_indent ~= false and vim.b[buf].snacks_indent ~= false and vim.bo[buf].buftype == ""
      end,
    },
    input = { enabled = true },

    -- TODO: (high priority) this one doesn't work. It should work on <leader>fg (grep word)
    -- as a sidenote, it should work even in insert mode, since you could press the arrows while on insert mode
    -- to choose one item from the list.
    picker = {
      sources = {
        explorer = {
          on_show = function(picker)
            -- NOTE: Found this "on" in snacks source code.
            picker.layout.root:on("WinLeave", function()
              picker:close()
            end)
          end,
        },
      },
      win = {
        input = {
          keys = {
            ["<C-j>"] = move(6, "j"),
            ["<C-k>"] = move(6, "k"),
          },
        },
        list = {
          keys = {
            ["<C-j>"] = move(6, "j"),
            ["<C-k>"] = move(6, "k"),
          },
        },
      },
    },
    -- picker = { enabled = true },
    -- notifier = { enabled = true },
    -- quickfile = { enabled = true },
    -- scope = { enabled = true },
    -- scroll = { enabled = true },
    -- statuscolumn = { enabled = true },
    -- words = { enabled = true },
  },

  config = function(_, opts)
    close_zombie_snacks()
    require("snacks").setup(opts)
  end,
}
