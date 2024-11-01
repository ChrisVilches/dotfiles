local map = vim.keymap.set

map("n", "<C-l>", function()
  if require("utils").is_buffer_in_bufferline() then
    vim.cmd "BufferLineCycleNext"
  else
    vim.cmd "wincmd l"
  end
end, { desc = "navigate right (smart)" })

map("n", "<C-h>", function()
  if require("utils").is_buffer_in_bufferline() then
    vim.cmd "BufferLineCyclePrev"
  else
    vim.cmd "wincmd h"
  end
end, { desc = "navigate left (smart)" })

map("n", "<C-j>", "<C-w>j", { desc = "navigate down" })
map("n", "<C-k>", "<C-w>k", { desc = "navigate up" })

for i = 1, 6, 1 do
  map("n", "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<CR>", { desc = "tab " .. i })
end

map("n", "<leader>b", "<cmd>enew<CR>", { desc = "buffer new" })
map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })

map("n", "<leader><C-h>", "<cmd>BufferLineMovePrev<CR>", { desc = "buffer move prev" })
map("n", "<leader><C-l>", "<cmd>BufferLineMoveNext<CR>", { desc = "buffer move next" })

map("n", "<leader>tx", "<cmd> BufferLineCloseOthers <CR>", { desc = "close all tabs except current and unsaved" })

map("n", "<leader>x", function()
  local n = vim.fn.bufnr()

  if vim.bo[n].modified then
    vim.api.nvim_err_writeln "Needs to save before closing a buffer"
    return
  end

  local buf = require "bufferline"
  buf.move(1)
  buf.cycle(-1)
  vim.api.nvim_buf_delete(n, {})
end, { desc = "buffer close" })
