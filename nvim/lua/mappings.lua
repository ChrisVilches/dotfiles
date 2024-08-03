require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("i", "kj", "<ESC>")

-- Save file while inserting. Using <C-o>w doesn't format the file.
map("i", "<C-s>", "<Esc>:w<cr>i", { desc = "file save" })

-- Find and replace
map("n", "<leader>frl", ":s//g<Left><Left>", { desc = "find and replace (line)" })
map("n", "<leader>frg", ":%s//g<Left><Left>", { desc = "find and replace (global)" })

-- TODO: Shortcut for copying the file relative path.

-- Move tabs (a bit trash, because the entire sequence has to be pressed to do
-- multiple tab moves)
map("n", "<leader><tab>", function()
  require("nvchad.tabufline").move_buf(1)
end, { desc = "move tab ▶" })

map("n", "<leader><S-tab>", function()
  require("nvchad.tabufline").move_buf(-1)
end, { desc = "move tab ◀" })

-- Replace word under cursor, then continue replacing instances
-- by pressing ".", or skip using "n". Both directions.
map("n", "<leader>rx", "*``cgn", { desc = "replace under cursor" })
map("n", "<leader>RX", "#``cgN", { desc = "replace under cursor (backwards)" })

-- Word deletions (The CTRL-Backspace has to be C-H, but this conflicts
-- with the movement in insert mode). I'd prefer to not add these for now.
-- map("i", "<C-Del>", "<C-o>de", { silent = true, desc = "delete from cursor to ending word" })
-- map("i", "<C-Backspace>", "<C-w>")
-- map("n", "<C-Del>", "de", { silent = true, desc = "delete from cursor to ending word" })
-- map("n", "<C-Backspace>", "db")

-- TODO: Add these?
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
-- map("i", "<C-BS>", "<C-w>", { silent = true, desc = "delete from cursor to ending word" })
