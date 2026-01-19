-- Each plugin file may also have some mappings.
local map = vim.keymap.set

map("n", "<leader>to", require("todos").show_todos, { desc = "show todos", noremap = true, silent = true })
map("n", "<leader>wt", "<cmd>set wrap!<CR>", { desc = "wrap toggle" })

map("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })
map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "general copy whole file" })

map("n", "<leader>q", "<cmd>:q<CR>", { desc = "quit the current window", noremap = true, silent = true })
map("n", "<leader>Q", "<cmd>:qa<CR>", { desc = "quit all windows", noremap = true, silent = true })
-- TODO: --preview is bugged. When opened for the first time, it initially
-- focuses on the first file, but if you reopen it, it will focus on the
-- current file (the first behavior is incorrect).
map("n", "<leader>e", "<CMD>Oil --float --preview<CR>", { desc = "File explorer" })

-- Hover
-- Fixes inconsistent hover behavior in some LSPs (e.g., Golang opens a window
-- instead of a floating popup).
map("n", "K", function()
  local winid = require("ufo").peekFoldedLinesUnderCursor()
  if not winid then
    vim.lsp.buf.hover()
  end
end, { desc = "LSP Hover or fold peek", noremap = true, silent = true })

-- whichkey
map("n", "<leader>wK", "<cmd>WhichKey <CR>", { desc = "whichkey all keymaps" })

map("n", "<leader>wk", function()
  vim.cmd("WhichKey " .. vim.fn.input "WhichKey: ")
end, { desc = "whichkey query lookup" })

-- markdown
map("n", "<leader>m!", "<cmd>Markview toggle<CR>", { desc = "Markdown: toggle" })

-- window size
map("n", "<c-w><<", "15<c-w><")
map("n", "<c-w>>>", "15<c-w>>")
