-- Each plugin file may also have some mappings.
local map = vim.keymap.set

map("n", "<leader>wt", "<cmd>set wrap!<CR>", { desc = "wrap toggle" })

-- Debugging stuff
map("n", "<leader>db", require("dap").toggle_breakpoint, { desc = "toggle breakpoint" })
map("n", "<leader>dc", require("dap").continue, { desc = "continue" })

map("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })
map("n", "<C-s>", "<cmd>w<CR>", { desc = "general save file" })
map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "general copy whole file" })

map("n", "<leader>fm", function()
  require("conform").format { lsp_fallback = true }
end, { desc = "general format file" })

map("t", "<C-x>", "<C-\\><C-N>", { desc = "terminal escape terminal mode" })

local terminal = require("toggleterm.terminal").Terminal:new { direction = "float" }

map({ "n", "t" }, "<A-i>", function()
  terminal:toggle()
end, { noremap = true, silent = true, desc = "terminal toggle floating term" })

-- whichkey
map("n", "<leader>wK", "<cmd>WhichKey <CR>", { desc = "whichkey all keymaps" })

map("n", "<leader>wk", function()
  vim.cmd("WhichKey " .. vim.fn.input "WhichKey: ")
end, { desc = "whichkey query lookup" })
