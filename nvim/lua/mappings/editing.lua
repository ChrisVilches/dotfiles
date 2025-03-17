-- Editing, motions, replacing, etc.
local map = vim.keymap.set

-- This overrides a native neovim keyboard shortcut that inserts a previously inserted text,
-- but I never used it, so it's alright. I prefer having the same setup as in a terminal so I can
-- get used to doing that motion both in Neovim and the terminal.
map("i", "<C-e>", "<End>", { desc = "move end of line" })
map("i", "<C-a>", "<ESC>I", { desc = "move beginning of line" })

map({ "i", "n" }, "<C-s>", function()
  vim.api.nvim_command "write"
end, { desc = "file save" })

local patterns = require "pattern-tools"
-- Find and replace
map("n", "<leader>frl", patterns.find_and_replace_line, { desc = "find and replace (line)" })
map("n", "<leader>frg", patterns.find_and_replace_global, { desc = "find and replace (global)" })

-- TODO: Experimental
map("n", "<leader>frc", patterns.find_and_replace_global_confirm, { desc = "find and replace (global + confirm)" })
map({ "n", "x" }, "<leader>/", patterns.search_text, { desc = "set text as search pattern", silent = true })
map({ "n", "x" }, "<leader>e", patterns.edit_with_macro, { desc = "set as search and start macro", silent = true })
map("n", "<leader>rc", 'v"vy"vp', { desc = "repeat character", noremap = true })
map("n", "<leader>rw", 'viw"vye"vp', { desc = "repeat word", noremap = true })
map("n", "<leader>rW", 'viW"vyE"vp', { desc = "repeat WORD", noremap = true })

-- Move selected text.
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- Wrap text inside () or {}
-- Can then be removed using "tpope/vim-surround"
map("x", "<leader>(", '"zs(<C-r>z)<Esc>')
map("x", "<leader>{", '"zs{\n<C-r>z\n}<Esc>')

-- Wrap selected text or the word under the cursor with quotes
map("x", '<leader>"', '"zs"<C-r>z"<Esc>')
map("x", "<leader>'", "\"zs'<C-r>z'<Esc>")
map("n", '<leader>"', 'viW"zs"<C-r>z"<Esc>')
map("n", "<leader>'", "viW\"zs'<C-r>z'<Esc>")
map("n", "<leader>!", require "toggle-boolean", { desc = "toggle boolean" })
