local M = {}

-- NOTE: Avoid using :q to close a fullscreen window, as it may cause glitches and errors,
-- especially with plugins like Avante (AI plugin).
-- Instead, use the provided toggle function to safely close the window.

local fullscreen_win = nil
local cursor_moved_autocmd = nil

function M.toggle_fullscreen()
  if fullscreen_win ~= nil then
    vim.api.nvim_win_close(fullscreen_win, true)
    return
  end

  local utils = require "toggle-fullscreen.window-util"

  if utils.is_floating(vim.api.nvim_get_current_win()) then
    vim.api.nvim_err_writeln "Cannot set a floating window to fullscreen"
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local original_win = vim.api.nvim_get_current_win()

  fullscreen_win = utils.create_fullscreen_floating(buf)

  utils.copy_win_options(original_win, fullscreen_win)

  cursor_moved_autocmd = vim.api.nvim_create_autocmd("CursorMoved", {
    callback = function()
      if buf == vim.api.nvim_get_current_buf() then
        local cursor = vim.api.nvim_win_get_cursor(0)
        local row, col = cursor[1], cursor[2]
        vim.api.nvim_win_set_cursor(original_win, { row, col })
      end
    end,
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(fullscreen_win),
    once = true,
    callback = function()
      vim.api.nvim_win_close(fullscreen_win, true)
      vim.api.nvim_del_autocmd(cursor_moved_autocmd)
      fullscreen_win = nil
    end,
  })
end

return M
