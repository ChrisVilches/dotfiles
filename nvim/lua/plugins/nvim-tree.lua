local function preview_file_floating_window(file_path)
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
end

local function on_attach(bufnr)
  local api = require "nvim-tree.api"

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- default mappings
  api.config.mappings.default_on_attach(bufnr)

  vim.keymap.set("n", "<esc>", function()
    vim.cmd "noh"
    vim.cmd "wincmd l"
  end, opts "change to right window (and clear highlights)")

  -- custom mappings
  -- Make the info popup and navigation similar to the one in the code editor.
  vim.keymap.set("n", "K", api.node.show_info_popup, opts "Show information")
  vim.keymap.del("n", "<C-k>", { buffer = bufnr })

  vim.keymap.set("n", "p", function()
    local node = api.tree.get_node_under_cursor()

    if node and node.absolute_path and vim.fn.isdirectory(node.absolute_path) ~= 1 then
      preview_file_floating_window(node.absolute_path)
    end
  end, opts "Preview selected file in a floating window")
end

return {
  "nvim-tree/nvim-tree.lua",
  config = function()
    require("nvim-tree").setup {
      on_attach = on_attach,
      renderer = {
        root_folder_label = false,
      },
      update_focused_file = {
        enable = true,
      },
      filters = {
        enable = true,
        -- git_ignored = true,
        -- dotfiles = false,
        -- git_clean = false,
        -- no_buffer = false,
        -- no_bookmark = false,
        -- custom = {},
        -- custom = { ".git" },
      },
      -- git = {
      --   ignore = true,
      -- },
    }
  end,
}
