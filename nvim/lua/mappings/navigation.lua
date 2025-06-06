local map = vim.keymap.set

map({ "n", "x" }, "<C-j>", "6j")
map({ "n", "x" }, "<C-k>", "6k")

for i = 1, 6, 1 do
  map("n", "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<CR>", { desc = "tab " .. i })
end

map("n", "<leader>b", "<cmd>enew<CR>", { desc = "buffer new" })
map("n", "<leader>fe", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })

map("n", "<leader>h", "<cmd>BufferLineCyclePrev<cr>", { desc = "tab prev" })
map("n", "<leader>l", "<cmd>BufferLineCycleNext<cr>", { desc = "tab next" })
map("n", "<leader><C-h>", "<cmd>BufferLineMovePrev<CR>", { desc = "buffer move prev" })
map("n", "<leader><C-l>", "<cmd>BufferLineMoveNext<CR>", { desc = "buffer move next" })

map(
  "n",
  "<leader>tx",
  require("buffer-close").close_other_except_unsaved,
  { desc = "close all tabs except current and unsaved" }
)

map("n", "<leader>x", require("buffer-close").close, { desc = "buffer close" })
map("n", "<leader>X", require("buffer-close").close_force, { desc = "buffer close (force)" })
map("n", "<leader>tr", require("buffer-close").reopen_last, { desc = "tab re-open" })
