-- TODO: No longer "chad" since I modified it quite a bit. Merge it with the other mappings file,
-- or split the mappings into multiple files, but don't call it "chad".
-- At least move this to the mappings folder after the next commit (not right away because that makes
-- it difficult to know what changes.)
local map = vim.keymap.set

map("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })

map("n", "<C-s>", "<cmd>w<CR>", { desc = "general save file" })
map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "general copy whole file" })

map("n", "<leader>n", "<cmd>set nu!<CR>", { desc = "toggle line number" })
map("n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "toggle relative number" })
map("n", "<leader>ch", "<cmd>NvCheatsheet<CR>", { desc = "toggle nvcheatsheet" })

map("n", "<leader>fm", function()
  require("conform").format { lsp_fallback = true }
end, { desc = "general format file" })

-- global lsp mappings
map("n", "<leader>ds", vim.diagnostic.setloclist, { desc = "LSP diagnostic loclist" })

-- Tabs
map("n", "<leader>b", "<cmd>enew<CR>", { desc = "buffer new" })

for i = 1, 6, 1 do
  map("n", "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<CR>", { desc = "tab " .. i })
end

-- map("n", "<tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "buffer goto next" })
-- map("n", "<S-tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "buffer goto prev" })
-- TODO: This one is a bit trash... it removes the buffer, and then goes to the first one to the right.
-- It should move to a tab that's adjacent to the deleted one.
-- map("n", "<leader>x", "<cmd>bd<CR><cmd>bn<CR>", { desc = "buffer close" })
-- TODO: I think this one is not trash. It focuses on an adjacent tab. Beta version. Test more.
map("n", "<leader>x", function()
  local n = vim.fn.bufnr()

  if vim.bo[n].modified then
    vim.api.nvim_err_writeln "Needs to save before closing a buffer"
    return
  end

  -- TODO: Nice, however when the last tab has been closed, it goes to the first one!!
  -- Fixed. I fixed it because "move" doesn't cycle, therefore it's possible to move one position
  -- so that the one to delete is never the last, and then manipulate the order to close one that
  -- prevents the weird cycling. Still beta and needs a bit more tests anyway.

  local buf = require "bufferline"
  buf.move(1)
  buf.cycle(-1)
  vim.api.nvim_buf_delete(n, {})
end, { desc = "buffer close" })

map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })

-- telescope
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

-- TODO: Learn this one. Seems useful. It allows you to move in a Vim-like way and copy stuff in the terminal.
-- But perhaps it's hard to manipulate the terminal when CTRL+C is mapped to "copy all lines".
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
