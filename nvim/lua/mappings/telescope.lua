local function map(keymap, telescope_cmd, desc)
  vim.keymap.set(
    "n",
    "<leader>" .. keymap,
    "<cmd>Telescope " .. telescope_cmd .. "<CR>",
    { desc = "Telescope: " .. desc }
  )
end

-- More pickers: https://github.com/nvim-telescope/telescope.nvim?tab=readme-ov-file#pickers
map("fw", "live_grep theme=ivy", "live grep")
map("fh", "help_tags", "help page")
map("ma", "marks", "find marks")
map("fo", "oldfiles", "find oldfiles")
map("fz", "current_buffer_fuzzy_find", "find in current buffer")
map("flb", "lsp_document_symbols", "Lists LSP document symbols in the current buffer")
map("flw", "lsp_workspace_symbols", "Lists LSP document symbols in the current workspace")
map("cm", "git_commits", "git commits")
map("gt", "git_status", "git status")
map("fa", "find_files follow=true no_ignore=true hidden=true", "find all files")
map("<tab>", "buffers", "show current buffers")

vim.keymap.set("n", "<leader>re", function()
  require("telescope.builtin").registers { initial_mode = "normal" }
end)

-- NOTE: Using Snacks instead of Telescope (TODO: maybe move somewhere else)
vim.keymap.set("n", "<leader>ff", function()
  Snacks.picker.files { matcher = { frecency = true } }
end)

vim.keymap.set("n", "<leader>fg", function()
  require("snacks.picker").grep_word()
end)

vim.keymap.set("n", "<leader>:", function()
  require("snacks.picker").command_history()
end)

vim.keymap.set("n", "<leader>th", function()
  require("telescope.builtin").colorscheme { enable_preview = true }
end, { desc = "theme picker" })
