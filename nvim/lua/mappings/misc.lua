-- Each plugin file may also have some mappings.
local map = vim.keymap.set

map("n", "<leader>wt", "<cmd>set wrap!<CR>", { desc = "wrap toggle" })
map("n", "<leader>sl", "<cmd>rightbelow vsplit<CR>", { desc = "split window right" })
map("n", "<leader>sj", "<cmd>rightbelow split<CR>", { desc = "split window down" })

-- Debugging stuff
map("n", "<leader>db", require("dap").toggle_breakpoint, { desc = "toggle breakpoint" })
map("n", "<leader>dc", require("dap").continue, { desc = "continue" })

map("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })
map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "general copy whole file" })

map("n", "<leader>q", "<cmd>:q<CR>", { desc = "quit the current window", noremap = true, silent = true })
map("n", "<leader>Q", "<cmd>:qa<CR>", { desc = "quit all windows", noremap = true, silent = true })

map("n", "<leader>fm", function()
  require("conform").format { lsp_fallback = true }
end, { desc = "general format file" })

map("t", "<Esc>", "<C-\\><C-N>", { desc = "terminal escape terminal mode" })

local terminal = require("toggleterm.terminal").Terminal:new { direction = "float" }

map({ "n", "t" }, "<A-i>", function()
  terminal:toggle()
end, { noremap = true, silent = true, desc = "terminal toggle floating term" })

-- whichkey
map("n", "<leader>wK", "<cmd>WhichKey <CR>", { desc = "whichkey all keymaps" })

map("n", "<leader>wk", function()
  vim.cmd("WhichKey " .. vim.fn.input "WhichKey: ")
end, { desc = "whichkey query lookup" })

map("n", "<leader>z", require "toggle-fullscreen", { noremap = true, silent = true })
map("n", "-", "<CMD>Oil --float --preview<CR>", { desc = "Oil: open parent directory" })
