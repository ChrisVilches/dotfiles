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

map({ "n", "x" }, "<C-j>", "6j")
map({ "n", "x" }, "<C-k>", "6k")

for i = 1, 6, 1 do
  map("n", "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<CR>", { desc = "tab " .. i })
end

map("n", "<leader>b", "<cmd>enew<CR>", { desc = "buffer new" })
map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })

map("n", "<leader><C-h>", "<cmd>BufferLineMovePrev<CR>", { desc = "buffer move prev" })
map("n", "<leader><C-l>", "<cmd>BufferLineMoveNext<CR>", { desc = "buffer move next" })

map(
  "n",
  "<leader>tx",
  require("utils").close_other_except_unsaved,
  { desc = "close all tabs except current and unsaved" }
)

map("n", "<leader>x", function()
  require("utils").close_buffer { force = false }
end, { desc = "buffer close" })

map("n", "<leader>X", function()
  require("utils").close_buffer { force = true }
end, { desc = "buffer close (force)" })
