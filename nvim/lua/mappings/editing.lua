-- Editing, motions, replacing, etc.
local map = vim.keymap.set

-- This overrides a native neovim keyboard shortcut that inserts a previously inserted text,
-- but I never used it, so it's alright. I prefer having the same setup as in a terminal so I can
-- get used to doing that motion both in Neovim and the terminal.
map("i", "<C-e>", "<End>", { desc = "move end of line" })
map("i", "<C-a>", "<ESC>I", { desc = "move beginning of line" })
map("i", "<C-d>", "<ESC><Right>ce")

-- Exit parentheses while editing.
-- TODO: It has a slight bug. Since block ending braces } never have a trailing space, this will
-- find the next brace at the same position twice. it7s kinda weird. Maybe this happens with lines ending in parentehses
-- but keep in mind this never happens in C++ due to the semicolon requirement.
-- Removing the 'c' flag kinda works, but adds a new problem (some parentheses that are together get skipped)
-- TODO: Bug fixed (by adding Left).
map("i", "<C-l>", "<Left><c-o>:call search('}\\|)\\|]\\|>\\|\"', 'W')<cr><Right>")

-- Save file while inserting. Using <C-o>w doesn't format the file.
map("i", "<C-s>", "<Esc>:w<cr>i", { desc = "file save" })

-- Find and replace
map("n", "<leader>frl", ":s///g<Left><Left><Left>", { desc = "find and replace (line)" })
map("n", "<leader>frg", ":%s///g<Left><Left><Left>", { desc = "find and replace (global)" })

-- Replace word under cursor, then continue replacing instances
-- by pressing ".", or skip using "n". Both directions.
map("n", "<leader>rx", ":let @/ = expand('<cword>')<CR>" .. "cgn", { desc = "replace under cursor" })
map("v", "<leader>rx", '"vy' .. ":let @/ = @v<CR>" .. "cgn", { desc = "replace under cursor" })

-- Move selected text.
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")
map("x", "<leader>pp", '"_dP', { desc = "paste and keep content" })

-- Wrap text inside () or {}
-- Can then be removed using "tpope/vim-surround"
map("x", "(", '"zs(<C-r>z)<Esc>')
map("x", "{", '"zs{\n<C-r>z\n}<Esc>')
