local map = vim.keymap.set

-- More pickers: https://github.com/nvim-telescope/telescope.nvim?tab=readme-ov-file#pickers
map("n", "<leader>fw", "<cmd>Telescope live_grep<CR>", { desc = "telescope live grep" })
map("n", "<leader>fg", "<cmd>Telescope grep_string<CR>", { desc = "telescope grep string" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "telescope help page" })
map("n", "<leader>ma", "<cmd>Telescope marks<CR>", { desc = "telescope find marks" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", { desc = "telescope find oldfiles" })
map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "telescope find in current buffer" })
map("n", "<leader>cm", "<cmd>Telescope git_commits<CR>", { desc = "telescope git commits" })
map("n", "<leader>gt", "<cmd>Telescope git_status<CR>", { desc = "telescope git status" })
map("n", "<leader>pt", "<cmd>Telescope terms<CR>", { desc = "telescope pick hidden term" })
-- This kinda works (shows the full diagnostic message) but still truncates it most of the times.
-- At least it's much better than before.
map(
  "n",
  "<leader>ds",
  "<cmd>:Telescope diagnostics wrap_results=true line_width=1000000<CR>",
  { desc = "telescope diagnostics" }
)

map(
  "n",
  "<leader>fa",
  "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
  { desc = "telescope find all files" }
)

map("n", "<leader>ff", "<cmd> Telescope frecency workspace=CWD <CR>", { desc = "find files (frecency)" })

map("n", "<leader>re", function()
  require("telescope.builtin").registers { initial_mode = "normal" }
end)

map("n", "<leader><tab>", function()
  require("telescope.builtin").buffers { initial_mode = "normal" }
end)
