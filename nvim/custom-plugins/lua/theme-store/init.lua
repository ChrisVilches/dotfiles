local M = {}

local json = require "theme-store.json"

local function get_theme_path()
  return vim.fn.stdpath "data" .. "/selected-theme"
end

function M.save(theme)
  local themepath = get_theme_path()
  local curr = json.load(themepath) or {}
  local project = vim.fn.getcwd()
  curr[project] = theme
  json.save(themepath, curr)
end

function M.load()
  local themepath = get_theme_path()
  local project = vim.fn.getcwd()
  local all_themes = json.load(themepath)
  if all_themes == nil then
    return nil
  end

  return all_themes[project]
end

return M
