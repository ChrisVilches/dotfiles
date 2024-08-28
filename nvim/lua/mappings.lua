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
vim.keymap.del("n", "<leader>e") -- Remove file explorer binding (nvchad)
-- Get used to using ctrl+w plus arrows for window navigation. TODO: Remove this comment.
-- the reason is that sometimes there are more windows visible, such as popups, debugger panels,
-- and stuff. and those windows can only be accessed with the arrows, not with a toggle thingy.
-- map("n", "<leader>e", require("utils").toggle_tree_code, { desc = "toggle tree/code" })

map({ "n", "x" }, ";", ":", { desc = "CMD enter command mode" })

-- Save file while inserting. Using <C-o>w doesn't format the file.
map("i", "<C-s>", "<Esc>:w<cr>i", { desc = "file save" })

-- Find and replace
map("n", "<leader>frl", ":s///g<Left><Left><Left>", { desc = "find and replace (line)" })
map("n", "<leader>frg", ":%s///g<Left><Left><Left>", { desc = "find and replace (global)" })

map("n", "<leader><tab>", function()
  require("buffer_manager.ui").toggle_quick_menu()
end)

-- Replace word under cursor, then continue replacing instances
-- by pressing ".", or skip using "n". Both directions.
map("n", "<leader>rx", "*``cgn", { desc = "replace under cursor" })
map("n", "<leader>RX", "#``cgN", { desc = "replace under cursor (backwards)" })

-- Move selected text.
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")
-- TODO: Sometimes it removes a space before the pasted word.
map("x", "<leader>pp", '"_dP', { desc = "paste and keep content" })

-- TODO: See from 27:15 (the yanking keybindings), and copy some.
-- https://www.youtube.com/watch?v=w7i4amO_zaE

-- Dope as hell. Now testing. TODO: Keep testing, remove comment in the future.
-- Can then be removed using "tpope/vim-surround"
map("x", "(", '""s(<C-r>")<Esc>')
-- All the extra stuff is for removing the empty line that sometimes arises.
local remove_empty_line = [[:if getline('.') == '' | execute 'normal! "_ddk' | endif]]
map("x", "{", '""s{\n<C-r>"\n}<Esc>va{V=%k' .. remove_empty_line .. "<CR>", { silent = true })

-- Debugging stuff
map("n", "<leader>db", require("dap").toggle_breakpoint, { desc = "toggle breakpoint" })
map("n", "<leader>dc", require("dap").continue, { desc = "continue" })
