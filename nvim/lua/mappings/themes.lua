local map = vim.keymap.set

map("n", "<leader>th", function()
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"

  require("telescope.builtin").colorscheme {
    initial_mode = "normal",
    enable_preview = true,
    attach_mappings = function()
      actions.select_default:replace(function(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        require("theme-store").save(selection.value)
        vim.cmd("colorscheme " .. selection.value)
      end)
      return true
    end,
  }
end, { desc = "theme picker" })

require("theme-cycle").on_change(require("theme-store").save)
require("theme-cycle").set_fav_themes {
  "ayu",
  "retroblue",
  "retroblue-darker",
  "catppuccin-mocha",
  "catppuccin-frappe",
  "catppuccin-macchiato",
  "github_dark",
  "github_dark_dimmed",
  "github_dark_high_contrast",
  "kanagawa-wave",
  "kanagawa-dragon",
  "tokyonight",
  "tokyonight-moon",
  "tokyonight-storm",
  "gruvbox",
}

map("n", "<leader>tn", require("theme-cycle").cycle_next, { desc = "theme favorite next" })
map("n", "<leader>tp", require("theme-cycle").cycle_prev, { desc = "theme favorite prev" })
