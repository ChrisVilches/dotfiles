local M = {}

local curr_theme_idx

local fav_themes = {}

local on_theme_changed_callback = nil

local function init_idx()
  curr_theme_idx = 0

  -- Try to find the current theme (only happens once)
  -- After that, if you change the theme manually but then use this function,
  -- it will still use this variable to know which theme to choose next.
  for index, theme in ipairs(fav_themes) do
    if theme == vim.g.colors_name then
      curr_theme_idx = index - 1
      break
    end
  end
end

local function cycle_fav_themes(change)
  local n = #fav_themes

  if n == 0 then
    return
  end

  curr_theme_idx = (curr_theme_idx + change + n) % n

  local theme = fav_themes[curr_theme_idx + 1]
  vim.cmd("colorscheme " .. theme)

  if on_theme_changed_callback ~= nil then
    on_theme_changed_callback(theme)
  end
end

function M.cycle_next()
  cycle_fav_themes(1)
end

function M.cycle_prev()
  cycle_fav_themes(-1)
end

function M.set_fav_themes(themes)
  fav_themes = themes
  init_idx()
end

function M.on_change(cb)
  on_theme_changed_callback = cb
end

return M
