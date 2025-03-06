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
    nvim_tree_api.tree.open()
    nvim_tree_api.tree.change_root(vim.fn.getcwd())
    nvim_tree_api.tree.reload()
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

  preview_file_floating_window = function(file_path)
    local buf = vim.api.nvim_create_buf(false, true)
    -- TODO: Sometimes I see the error "failed to rename buffer". Not sure how to reproduce it.
    -- but in most cases, the error doesn't happen.
    vim.api.nvim_buf_set_name(buf, file_path)
    vim.fn.setbufline(buf, 1, vim.fn.readfile(file_path))

    vim.api.nvim_buf_set_option(buf, "modifiable", false)

    local win_opts = {
      relative = "editor",
      width = 80,
      height = 20,
      col = math.floor((vim.o.columns - 80) / 2),
      row = math.floor((vim.o.lines - 20) / 2),
      style = "minimal",
      border = "rounded",
    }

    -- TODO: Maybe add "desc" to all these mappings inside the floating window. Or create a helper function to make it cleaner.
    -- (similar to the helper function in nvim-tree.lua)
    local win = vim.api.nvim_open_win(buf, true, win_opts)
    vim.api.nvim_win_set_option(win, "number", true)
    vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":q!<CR>", { noremap = true, silent = true })

    vim.cmd "filetype detect"
    vim.cmd "syntax enable"

    vim.keymap.set("n", "<CR>", function()
      vim.api.nvim_win_close(win, true)
      vim.cmd("edit " .. file_path)
    end, { buffer = buf, noremap = true, silent = true })

    vim.api.nvim_create_autocmd("WinLeave", {
      group = vim.api.nvim_create_augroup("FloatingWindowBlur", { clear = true }),
      pattern = "*",
      callback = function()
        if vim.api.nvim_get_current_win() == win then
          vim.api.nvim_win_close(win, true)
        end
      end,
    })
  end,
}
