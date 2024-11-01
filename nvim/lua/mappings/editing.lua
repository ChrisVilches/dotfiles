-- Editing, motions, replacing, etc.
local map = vim.keymap.set

-- TODO: This superuser exchange answer has some nice mappings for navigation while in insertion mode,
-- it has some that I already do, such as CTRL+a, CTRL+e, etc
-- https://superuser.com/questions/706674/moving-to-the-beginning-of-line-within-vim-insert-mode#:~:text=Ctrl%20%2B%20a%20%3A%20Go%20to%20beginning,Normal%20Mode%20%26%26%20Insert%20Mode%5D
-- Maybe try to add some?

-- This overrides a native neovim keyboard shortcut that inserts a previously inserted text,
-- but I never used it, so it's alright. I prefer having the same setup as in a terminal so I can
-- get used to doing that motion both in Neovim and the terminal.
map("i", "<C-e>", "<End>", { desc = "move end of line" })
map("i", "<C-a>", "<ESC>I", { desc = "move beginning of line" })

-- Save file while inserting. Using <C-o>w doesn't format the file.
map("i", "<C-s>", "<Esc>:w<cr>i", { desc = "file save" })

-- Find and replace
map("n", "<leader>frl", ":s///g<Left><Left><Left>", { desc = "find and replace (line)" })
map("n", "<leader>frg", ":%s///g<Left><Left><Left>", { desc = "find and replace (global)" })

-- Replace word under cursor, then continue replacing instances
-- by pressing ".", or skip using "n". Both directions.
map("n", "<leader>rx", "*``cgn", { desc = "replace under cursor" })
map("n", "<leader>RX", "#``cgN", { desc = "replace under cursor (backwards)" })

-- Move selected text.
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")
map("x", "<leader>pp", '"_dP', { desc = "paste and keep content" })

-- Can then be removed using "tpope/vim-surround"
map("x", "(", '""s(<C-r>")<Esc>')
-- All the extra stuff is for removing the empty line that sometimes arises.
local remove_empty_line = [[:if getline('.') == '' | execute 'normal! "_ddk' | endif]]
map("x", "{", '""s{\n<C-r>"\n}<Esc>va{V=%k' .. remove_empty_line .. "<CR>", { silent = true })
