local M = {}

-- TODO: Doesn't load the theme when it's retroblue. But I think this may be an issue with the theme rather than
-- this plugin. Verify that.
function M.preview_file(file_path)
  if vim.fn.isdirectory(file_path) == 1 then
    vim.api.nvim_err_writeln("Cannot preview a directory (" .. file_path .. ")")
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)

  -- the "/preview/" prefix is used to avoid conflicts with
  -- existing buffers. without this line, the function
  -- crashes when the file is already open.
  vim.api.nvim_buf_set_name(buf, "/preview" .. file_path)

  vim.fn.setbufline(buf, 1, vim.fn.readfile(file_path))
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

  local win_opts = {
    relative = "editor",
    width = 80,
    height = 20,
    col = math.floor((vim.o.columns - 80) / 2),
    row = math.floor((vim.o.lines - 20) / 2),
    style = "minimal",
    border = "rounded",
  }

  local win = vim.api.nvim_open_win(buf, true, win_opts)
  -- TODO: These options should come from the globally configured options. Don't set them by myself.
  -- i.e. if the neovim config says "use relative numbers", it should use those opts.
  vim.api.nvim_set_option_value("number", true, { win = win })
  vim.api.nvim_buf_set_keymap(buf, "n", "<esc>", ":q!<cr>", { noremap = true, silent = true })

  -- the following line used to crash when previewing go files. but after doings some plugin cleaning,
  -- and updating, it got fixed. if this happens again, also try to remove sessions.
  -- maybe even try removing all plugins and re-installing them.
  vim.cmd "filetype detect"
  vim.cmd "syntax enable"

  -- this autocommand ensures proper rendering for certain filetypes, such as markdown with markview.
  -- if rendering issues persist, consider adding more autocommands.
  vim.api.nvim_exec_autocmds("bufenter", { buffer = buf })

  vim.keymap.set("n", "<cr>", function()
    vim.api.nvim_win_close(win, true)
    vim.cmd("edit " .. file_path)
  end, { buffer = buf, noremap = true, silent = true })

  vim.api.nvim_create_autocmd("winleave", {
    group = vim.api.nvim_create_augroup("floatingwindowblur", { clear = true }),
    pattern = "*",
    callback = function()
      if vim.api.nvim_get_current_win() == win then
        -- ensure the buffer is removed internally to prevent
        -- errors from conflicting buffer names.
        -- verify with ":ls!".
        vim.api.nvim_win_close(win, true)
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end,
  })
end

return M
