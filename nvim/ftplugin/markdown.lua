local buf = vim.api.nvim_get_current_buf()

local map = vim.keymap.set

local function opts(desc)
  return { desc = "markdown: " .. desc, buffer = buf, noremap = true, silent = true, nowait = true }
end

map("n", "<leader>ok", "^f[ax<esc>", opts "Mark to-do item as completed")
