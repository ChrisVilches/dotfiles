local M = {}

-- TODO: Doesn't load the theme when it's retroblue. But I think this may be an issue with the theme rather than
-- this plugin. Verify that.

local fullscreen_win = nil
local cursor_moved_autocmd = nil

function M.toggle_fullscreen()
  if fullscreen_win ~= nil then
    vim.api.nvim_win_close(fullscreen_win, true)
    -- TODO: This still glitches sometimes. I get the CursorMoved error.
    -- Try doing it with the Avante sidebar a lot of times. It will glitch.
    -- I think this is a limitation of Avante. I also saw this same issue
    -- with another plugin and couldn't make it work.
    -- It's a very small limitation though. Somehow just tell the user to enforce using <leader>z
    -- instead of a hard :q which may mess things up.
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

  local on_cursor_move = function()
    if buf == vim.api.nvim_get_current_buf() then
      local cursor = vim.api.nvim_win_get_cursor(0)
      local row, col = cursor[1], cursor[2]
      vim.api.nvim_win_set_cursor(original_win, { row, col })
    end
  end

  cursor_moved_autocmd = vim.api.nvim_create_autocmd("CursorMoved", {
    callback = on_cursor_move,
  })

  local cleanup = function()
    vim.api.nvim_win_close(fullscreen_win, true)
    vim.api.nvim_del_autocmd(cursor_moved_autocmd)
    fullscreen_win = nil
  end

  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(fullscreen_win),
    once = true,
    callback = cleanup,
  })
end

return M
