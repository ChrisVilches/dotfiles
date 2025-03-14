local M = {}

local function inherit_option(win, key)
  vim.api.nvim_set_option_value(key, vim.go[key], { win = win })
end

local function create_window(buf, title)
  local win_opts = {
    relative = "editor",
    width = 80,
    height = 20,
    col = math.floor((vim.o.columns - 80) / 2),
    row = math.floor((vim.o.lines - 20) / 2),
    style = "minimal",
    border = "rounded",
    title = title,
  }

  local win = vim.api.nvim_open_win(buf, true, win_opts)

  vim.api.nvim_set_option_value("winfixbuf", true, { win = win })
  inherit_option(win, "number")
  inherit_option(win, "relativenumber")
  inherit_option(win, "cursorline")
  inherit_option(win, "cursorcolumn")
  inherit_option(win, "colorcolumn")
  inherit_option(win, "signcolumn")
  inherit_option(win, "foldcolumn")
  inherit_option(win, "winhighlight")
  inherit_option(win, "wrap")
  inherit_option(win, "scrolloff")
  inherit_option(win, "sidescrolloff")
  return win
end

local function map_edit_on_enter(win, buf, file_path)
  vim.keymap.set("n", "<cr>", function()
    vim.api.nvim_win_close(win, true)
    vim.cmd("edit " .. file_path)
  end, { buffer = buf, noremap = true, silent = true })
end

local function set_on_blur_close(win, buf)
  vim.api.nvim_create_autocmd("WinLeave", {
    pattern = "*",
    once = true,
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

local function create_buffer(file_path)
  local buf = vim.api.nvim_create_buf(false, true)

  -- the "/preview/" prefix is used to avoid conflicts with
  -- existing buffers. without this line, the function
  -- crashes when the file is already open.
  vim.api.nvim_buf_set_name(buf, "/preview" .. file_path)

  vim.fn.setbufline(buf, 1, vim.fn.readfile(file_path))
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
  vim.api.nvim_buf_set_keymap(buf, "n", "<esc>", ":q!<cr>", { noremap = true, silent = true })

  vim.api.nvim_buf_call(buf, function()
    vim.cmd "doautocmd BufEnter"
    vim.cmd "filetype detect"
    vim.cmd "syntax enable"
  end)

  return buf
end

function M.preview_file(file_path)
  if vim.fn.isdirectory(file_path) == 1 then
    vim.api.nvim_err_writeln("Cannot preview a directory (" .. file_path .. ")")
    return
  end

  local buf = create_buffer(file_path)
  local win_title = vim.fn.fnamemodify(file_path, ":~:.")
  local win = create_window(buf, win_title)

  map_edit_on_enter(win, buf, file_path)
  set_on_blur_close(win, buf)
end

return M
