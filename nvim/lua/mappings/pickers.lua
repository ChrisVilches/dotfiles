local function map(keymap, telescope_cmd, desc)
  vim.keymap.set(
    "n",
    "<leader>" .. keymap,
    "<cmd>Telescope " .. telescope_cmd .. "<CR>",
    { desc = "Telescope: " .. desc }
  )
end

-- More pickers: https://github.com/nvim-telescope/telescope.nvim?tab=readme-ov-file#pickers
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

local picker = require "snacks.picker"

vim.keymap.set("n", "<leader>th", picker.colorschemes, { desc = "theme picker" })
vim.keymap.set("n", "<leader>fw", picker.grep, { desc = "grep" })
vim.keymap.set("n", "<leader>fg", picker.grep_word, { desc = "grep word" })
vim.keymap.set("n", "<leader>:", picker.command_history, { desc = "command history" })

vim.keymap.set("n", "<leader>ff", function()
  picker.files { matcher = { frecency = true } }
end, { desc = "find files" })
