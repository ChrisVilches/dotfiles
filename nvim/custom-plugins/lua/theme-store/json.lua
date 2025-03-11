local M = {}

function M.load(file_path)
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

function M.save(file_path, data)
  local file = io.open(file_path, "w")
  if not file then
    error("Could not open file for writing: " .. file_path)
    return
  end
  file:write(vim.fn.json_encode(data) .. "\n")
  file:close()
end

return M
