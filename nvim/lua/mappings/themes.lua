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
        require("utils").save_theme(selection.value)
        vim.cmd("colorscheme " .. selection.value)
      end)
      return true
    end,
  }
end, { desc = "theme picker" })

local fav_themes = {
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

local fav_theme_idx = -1

local function cycle_fav_themes(is_next)
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
  cycle_fav_themes(true)
end, { desc = "theme favorite next" })

map("n", "<leader>tp", function()
  cycle_fav_themes(false)
end, { desc = "theme favorite prev" })
