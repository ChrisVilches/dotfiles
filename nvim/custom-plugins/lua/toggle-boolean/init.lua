local function is_char_alpha(char)
  return char:match "%a" ~= nil
end

local function current_char_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.fn.col "."
  return line:sub(col, col)
end

local toggle_map = {
  ["false"] = "true",
  ["true"] = "false",
  ["False"] = "True",
  ["True"] = "False",
}

return function()
  -- This is a hack to avoid toggling booleans in these situations:
  -- some_var=True (python) when the cursor is on the =.
  -- [true, false, false] when the cursor is on a comma.
  if not is_char_alpha(current_char_under_cursor()) then
    return
  end

  local current_word = vim.fn.expand "<cword>"
  local replacement = toggle_map[current_word]

  if replacement then
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd("normal! ciw" .. replacement)
    vim.api.nvim_win_set_cursor(0, cursor_pos)
  end
end
