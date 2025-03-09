-- Each plugin file may also have some mappings.
local map = vim.keymap.set

map("n", "<leader>wt", "<cmd>set wrap!<CR>", { desc = "wrap toggle" })
map("n", "<leader>sl", "<cmd>rightbelow vsplit<CR>", { desc = "split window right" })
map("n", "<leader>sj", "<cmd>rightbelow split<CR>", { desc = "split window down" })

-- Debugging stuff
map("n", "<leader>db", require("dap").toggle_breakpoint, { desc = "toggle breakpoint" })
map("n", "<leader>dc", require("dap").continue, { desc = "continue" })

map("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })
map("n", "<C-s>", "<cmd>w<CR>", { desc = "general save file" })
map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "general copy whole file" })

map("n", "<leader>q", function()
  local wins = vim.api.nvim_list_wins()
  local current_buf = vim.api.nvim_get_current_buf()
  local is_nvimtree = vim.bo[current_buf].filetype == "NvimTree"

  -- If nvim-tree is the last window open, the cursor position will be saved to it.
  -- This is inconvenient because I want the cursor position to be restored to the
  -- code window by the sessions plugin. To address this, all windows are closed
  -- when nvim-tree would be the last remaining one, ensuring the cursor position
  -- remains on the code window for the next session.
  -- This is also convenient because I don't have to execute this keymap twice in order to
  -- close the code and then the nvim-tree.
  if #wins == 2 and not is_nvimtree and require("utils").is_nvimtree_open() then
    vim.cmd "qa"
  else
    vim.cmd "q"
  end
end, { desc = "Quit the current window (or all if nvim-tree is last)", noremap = true, silent = true })

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
