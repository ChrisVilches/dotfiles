-- TODO: This opens the file with absolute path, which makes it too long.
-- Compare the original path with the newly opened one, and the new one is longer.
local function toggle_lang_view()
  local abs_path = vim.api.nvim_buf_get_name(0)
  if abs_path == "" then
    vim.notify("No file path", vim.log.levels.ERROR)
    return
  end

  local path = vim.fn.fnamemodify(abs_path, ":.")
  local alt_path

  if path:find "views_en" then
    alt_path = path:gsub("views_en", "views_ja")
  elseif path:find "views_ja" then
    alt_path = path:gsub("views_ja", "views_en")
  else
    vim.notify("Not a language-specific view file", vim.log.levels.ERROR)
    return
  end

  if vim.fn.filereadable(alt_path) == 1 then
    local row, col = unpack(vim.api.nvim_win_get_cursor(0)) -- current cursor position
    vim.cmd("edit " .. vim.fn.fnameescape(alt_path))
    -- Restore line (and same column too)
    pcall(vim.api.nvim_win_set_cursor, 0, { row, col })
  else
    vim.notify("Counterpart file does not exist: " .. alt_path, vim.log.levels.ERROR)
  end
end

vim.api.nvim_create_user_command("ToggleLangView", toggle_lang_view, {})
