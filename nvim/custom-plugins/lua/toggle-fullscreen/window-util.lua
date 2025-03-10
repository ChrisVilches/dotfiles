local M = {}

function M.is_floating(win_id)
  local config = vim.api.nvim_win_get_config(win_id)
  return config.relative ~= ""
end

function M.copy_win_options(src, dest)
  local function copy_opt(key)
    local src_val = vim.api.nvim_get_option_value(key, { win = src })
    vim.api.nvim_set_option_value(key, src_val, { win = dest })
  end
  copy_opt "number"
  copy_opt "relativenumber"
  copy_opt "cursorline"
  copy_opt "foldmethod"
  copy_opt "scrolloff"
  copy_opt "wrap"
  -- local cursor_pos = vim.api.nvim_win_get_cursor(src)
  -- vim.api.nvim_win_set_cursor(dest, cursor_pos)
  -- TODO: Syncing the scroll position would be nice as well. How to do it?
  -- problem: sometimes the vertical position (scrolling) are different (original vs preview windows)
end

function M.create_fullscreen_floating(buf)
  local ui = vim.api.nvim_list_uis()[1]

  -- TODO: It gets on top of the popup window when doing -> command line -> ctrl+f (show history - bug: not visible)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = ui.width,
    height = ui.height,
    row = 0,
    col = 0,
    style = "minimal",
    border = "solid",
  })

  -- This is to prevent switching to a different buffer. This window
  -- should only have the original buffer.
  vim.api.nvim_set_option_value("winfixbuf", true, { win = win })
  return win
end

return M
