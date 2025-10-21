local function map(keymap, telescope_cmd, desc)
  vim.keymap.set(
    "n",
    "<leader>" .. keymap,
    "<cmd>Telescope " .. telescope_cmd .. "<CR>",
    { desc = "Telescope: " .. desc }
  )
end

-- More pickers: https://github.com/nvim-telescope/telescope.nvim?tab=readme-ov-file#pickers
map("fw", "live_grep", "live grep")
map("fg", "grep_string", "grep string")
map("fh", "help_tags", "help page")
map("ma", "marks", "find marks")
map("fo", "oldfiles", "find oldfiles")
map("fz", "current_buffer_fuzzy_find", "find in current buffer")
map("flb", "lsp_document_symbols", "Lists LSP document symbols in the current buffer")
map("flw", "lsp_workspace_symbols", "Lists LSP document symbols in the current workspace")
map("cm", "git_commits", "git commits")
map("gt", "git_status", "git status")

-- This kinda works (shows the full diagnostic message) but still truncates it most of the times.
-- At least it's much better than before.
map("ds", "diagnostics wrap_results=true line_width=1000000", "diagnostics")
map("fa", "find_files follow=true no_ignore=true hidden=true", "find all files")
map("ff", "frecency workspace=CWD ", "find files (frecency)")

vim.keymap.set("n", "<leader>re", function()
  require("telescope.builtin").registers { initial_mode = "normal" }
end)

vim.keymap.set("n", "<leader><tab>", function()
  require("telescope.builtin").buffers { initial_mode = "normal" }
end)
