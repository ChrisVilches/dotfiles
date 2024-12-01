local map = vim.keymap.set

map("n", "<leader>th", function()
  local actions = require "telescope.actions"
  local action_set = require "telescope.actions.set"
  local action_state = require "telescope.actions.state"

  require("telescope.builtin").colorscheme {
    initial_mode = "normal",
    enable_preview = true,
    attach_mappings = function(prompt_bufnr, map_key)
      map_key("n", "<C-j>", function()
        action_set.shift_selection(prompt_bufnr, 6)
      end)
      map_key("n", "<C-k>", function()
        action_set.shift_selection(prompt_bufnr, -6)
      end)

      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        require("utils").save_theme(selection.value)
        vim.cmd("colorscheme " .. selection.value)
      end)
      return true
    end,
  }
end, { desc = "theme picker" })

local fav_themes = {
  "ayu",
  "borland",
  "blue",
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

local fav_theme_idx = -1

local function cycle_themes(is_next)
  -- Try to find the current theme (only happens once)
  -- After that, if you change the theme manually but then use this function,
  -- it will still use this variable to know which theme to choose next.
  if fav_theme_idx == -1 then
    for index, theme in ipairs(fav_themes) do
      if theme == vim.g.colors_name then
        fav_theme_idx = index - 1
        break
      end
    end
  end

  if fav_theme_idx == -1 then
    fav_theme_idx = 0
  end

  if is_next then
    fav_theme_idx = (fav_theme_idx + 1) % #fav_themes
  else
    fav_theme_idx = (fav_theme_idx - 1 + #fav_themes) % #fav_themes
  end

  local theme = fav_themes[fav_theme_idx + 1]
  vim.cmd("colorscheme " .. theme)
  require("utils").save_theme(theme)
end

map("n", "<leader>tn", function()
  cycle_themes(true)
end)

map("n", "<leader>tp", function()
  cycle_themes(false)
end)
