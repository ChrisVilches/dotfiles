require "nvchad.mappings"

local map = vim.keymap.set

-- Remove default insert mode movement mappings (nvchad).
-- A way to navigate using hjkl as arrows should be configured in the keyboard
-- globally, not just here in vim.
-- (For example if holding ESC enters the keyboard movement layer, then I have
-- both ESC and CTRL for the same thing, which makes it confusing so in that case just use ESC)
vim.keymap.del("i", "<C-h>")
vim.keymap.del("i", "<C-j>")
vim.keymap.del("i", "<C-k>")
vim.keymap.del("i", "<C-l>")
vim.keymap.del("n", "<leader>v") -- Remove terminal launcher (nvchad)

map("n", "<leader>e", require("utils").toggle_tree_code, { desc = "toggle tree/code" })

map({ "n", "x" }, ";", ":", { desc = "CMD enter command mode" })
-- These are a bit meh so I removed them (I never use them)

-- Save file while inserting. Using <C-o>w doesn't format the file.
map("i", "<C-s>", "<Esc>:w<cr>i", { desc = "file save" })

-- Find and replace
map("n", "<leader>frl", ":s///g<Left><Left><Left>", { desc = "find and replace (line)" })
map("n", "<leader>frg", ":%s///g<Left><Left><Left>", { desc = "find and replace (global)" })

-- TODO: Shortcut for copying the file relative path.

-- Move tabs (a bit trash, because the entire sequence has to be pressed to do
-- multiple tab moves)
-- TODO: The new shit is to stop using tabs. I have some plugins to check that may work better than tabs.
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

-- Move selected text.
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")
-- TODO: I think this one doesn't work, because the sequence conflicts with a longer one.
-- I think that won't work sometimes if some plugins haven't been lazy-initialized.
map("x", "<leader>p", '"_dP', { desc = "paste and keep content" })

-- TODO: See from 27:15 (the yanking keybindings), and copy some.
-- https://www.youtube.com/watch?v=w7i4amO_zaE
