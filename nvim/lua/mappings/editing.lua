-- Editing, motions, replacing, etc.
local map = vim.keymap.set

-- TODO: I need more useful commands for like, pasting (and managing registers effectively) and
-- things like macros or multicursor (for when I use Tailwind), but don't add just whatever you
-- find online. Try to make them useful for me and to start using them a lot.
-- Maybe try to learn how to search history of edits (maybe the overriden keymappings below would help,
-- but I think there are others that let you open a popup to autocomplete using your previous inserts)

-- This overrides a native neovim keyboard shortcut that inserts a previously inserted text,
-- but I never used it, so it's alright. I prefer having the same setup as in a terminal so I can
-- get used to doing that motion both in Neovim and the terminal.
map("i", "<C-e>", "<End>", { desc = "move end of line" })
map("i", "<C-a>", "<ESC>I", { desc = "move beginning of line" })

-- TODO: Maybe remove. I never use it, I find it confusing to have this.
-- map("i", "<C-d>", "<ESC><Right>ce")

-- Exit parentheses while editing.
-- TODO: Maybe remove. I never use it, I find it confusing to have this.
-- map("i", "<C-l>", "<Left><c-o>:call search('}\\|)\\|]\\|>\\|\"', 'W')<cr><Right>", { silent = true })

map({ "i", "n" }, "<C-s>", function()
  vim.api.nvim_command "write"
end, { desc = "file save" })

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
map("x", "<leader>p", '"_dP', { desc = "paste and keep content" })

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
