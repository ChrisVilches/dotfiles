local M = {}

-- Known issues:
-- * Floating window uses different highlights, causing color inconsistency.
-- * Fullscreen floating window overlaps popup when using command line history.

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
end

function M.create_fullscreen_floating(buf)
  local ui = vim.api.nvim_list_uis()[1]

  local view = vim.fn.winsaveview()

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = ui.width,
    height = ui.height,
    row = 0,
    col = 0,
    style = "minimal",
    border = "solid",
  })

  -- Attempt to synchronize scroll and cursor positions.
  vim.fn.winrestview(view)

  -- This is to prevent switching to a different buffer. This window
  -- should only have the original buffer.
  vim.api.nvim_set_option_value("winfixbuf", true, { win = win })
  return win
end

return M
