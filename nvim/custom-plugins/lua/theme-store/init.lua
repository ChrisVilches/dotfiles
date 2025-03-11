local M = {}

local load_json = function(file_path)
  local file = io.open(file_path, "r")
  if not file then
    return nil
  end

  local content = file:read "*all"
  file:close()
  local success, result = pcall(vim.fn.json_decode, content)

  if success then
    return result
  else
    return nil
  end
end

local save_file = function(file_path, data)
  local file = io.open(file_path, "w")
  if not file then
    error("Could not open file for writing: " .. file_path)
    return
  end
  file:write(data .. "\n")
  file:close()
end

function M.save(theme)
  local themepath = vim.fn.stdpath "data" .. "/selected-theme"
  local curr = load_json(themepath) or {}
  local project = vim.fn.getcwd()
  curr[project] = theme
  save_file(themepath, vim.fn.json_encode(curr))
end

function M.load()
  local themepath = vim.fn.stdpath "data" .. "/selected-theme"
  local project = vim.fn.getcwd()
  local all_themes = load_json(themepath)
  if all_themes == nil then
    return nil
  end

  return all_themes[project]
end

return M
