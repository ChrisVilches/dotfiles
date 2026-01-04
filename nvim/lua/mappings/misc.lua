-- Each plugin file may also have some mappings.
local map = vim.keymap.set

map("n", "<leader>wt", "<cmd>set wrap!<CR>", { desc = "wrap toggle" })

-- Debugging stuff
map("n", "<leader>db", require("dap").toggle_breakpoint, { desc = "toggle breakpoint" })
map("n", "<leader>dc", require("dap").continue, { desc = "continue" })

map("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })
map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "general copy whole file" })

map("n", "<leader>q", "<cmd>:q<CR>", { desc = "quit the current window", noremap = true, silent = true })
map("n", "<leader>Q", "<cmd>:qa<CR>", { desc = "quit all windows", noremap = true, silent = true })

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

map("n", "<leader>z", require "toggle-fullscreen", { noremap = true, silent = true })
map("n", "-", "<CMD>Oil --float --preview<CR>", { desc = "Oil: open parent directory" })

-- markview
map("n", "<leader>m!", "<cmd>Markview toggle<CR>", { desc = "Markview: toggle" })

-- window size
map("n", "<c-w><<", "15<c-w><")
map("n", "<c-w>>>", "15<c-w>>")
