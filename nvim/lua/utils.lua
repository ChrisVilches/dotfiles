-- This function should return only buffers listed in the tabs.
-- Not sure if that's how it works.
local current_buffers = function()
  return vim.tbl_filter(function(buf)
    return vim.bo[buf].buflisted
  end, vim.api.nvim_list_bufs())
end

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

return {
  current_dir_is_git_repo = function()
    local cwd = vim.fn.getcwd()
    local res = vim.fn.glob(cwd .. "/.git/")
    return #res > 0
  end,

  save_theme = function(theme)
    local themepath = vim.fn.stdpath "data" .. "/selected-theme"
    local curr = load_json(themepath) or {}
    local project = vim.fn.getcwd()
    curr[project] = theme
    save_file(themepath, vim.fn.json_encode(curr))
  end,

  load_theme = function()
    local themepath = vim.fn.stdpath "data" .. "/selected-theme"
    local project = vim.fn.getcwd()
    local all_themes = load_json(themepath)
    if all_themes == nil then
      return nil
    end

    return all_themes[project]
  end,

  restore_nvim_tree = function()
    local nvim_tree_api = require "nvim-tree.api"

    -- Restore the nvim-tree while maintaining the cursor position in the code window.
    local win_id = vim.api.nvim_get_current_win()
    local cursor_pos = vim.api.nvim_win_get_cursor(win_id)
    nvim_tree_api.tree.open()
    nvim_tree_api.tree.change_root(vim.fn.getcwd())
    nvim_tree_api.tree.reload()
    vim.api.nvim_set_current_win(win_id)
    pcall(vim.api.nvim_win_set_cursor, win_id, cursor_pos)
  end,

  close_other_except_unsaved = function()
    local current_buf = vim.api.nvim_get_current_buf()

    for _, buf in ipairs(current_buffers()) do
      if buf ~= current_buf and not vim.bo[buf].modified then
        vim.api.nvim_buf_delete(buf, {})
      end
    end
  end,

  close_buffer = function(opts)
    local n = vim.fn.bufnr()
    local force = opts["force"]

    if not force and vim.bo[n].modified then
      local name = vim.api.nvim_buf_get_name(n)

      if name == nil or name == "" then
        name = "unnamed"
      end
      vim.api.nvim_err_writeln("Needs to save before closing a buffer (" .. name .. ")")
      return false
    end

    local buf = require "bufferline"
    buf.move(1)
    buf.cycle(-1)
    vim.api.nvim_buf_delete(n, { force = force })
    return true
  end,

  is_char_alpha = function(char)
    return char:match "%a" ~= nil
  end,

  current_char_under_cursor = function()
    local line = vim.api.nvim_get_current_line()
    local col = vim.fn.col "."
    return line:sub(col, col)
  end,
}
