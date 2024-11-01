local map = vim.keymap.set

map("n", "<leader>fw", "<cmd>Telescope live_grep<CR>", { desc = "telescope live grep" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "telescope help page" })
map("n", "<leader>ma", "<cmd>Telescope marks<CR>", { desc = "telescope find marks" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", { desc = "telescope find oldfiles" })
map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "telescope find in current buffer" })
map("n", "<leader>cm", "<cmd>Telescope git_commits<CR>", { desc = "telescope git commits" })
map("n", "<leader>gt", "<cmd>Telescope git_status<CR>", { desc = "telescope git status" })
map("n", "<leader>pt", "<cmd>Telescope terms<CR>", { desc = "telescope pick hidden term" })
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "telescope find files" })
map(
  "n",
  "<leader>fa",
  "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
  { desc = "telescope find all files" }
)

map("n", "<leader>ff", "<cmd> Telescope frecency workspace=CWD <CR>", { desc = "find files (frecency)" })

map("n", "<leader><tab>", function()
  require("telescope.builtin").buffers {
    initial_mode = "normal",
  }
end)

-- TODO: https://github.com/nvim-telescope/telescope.nvim?tab=readme-ov-file#pickers
-- This page has a lot of builtin Telescope finders.
-- But it's worth trying the other ones and see if I find a gem (I'm not talking about Ruby btw).
-- One in particular that I find interesting is probably this one: builtin.grep_string
