require "chad_mappings"
-- TODO: https://github.com/nvim-telescope/telescope.nvim?tab=readme-ov-file#pickers
-- This page has a lot of builtin Telescope finders.
-- But it's worth trying the other ones and see if I find a gem (I'm not talking about Ruby btw).

-- One in particular that I find interesting is probably this one: builtin.grep_string
-- TODO: This superuser exchange answer has some nice mappings for navigation while in insertion mode,
-- it has some that I already do, such as CTRL+a, CTRL+e, etc
-- https://superuser.com/questions/706674/moving-to-the-beginning-of-line-within-vim-insert-mode#:~:text=Ctrl%20%2B%20a%20%3A%20Go%20to%20beginning,Normal%20Mode%20%26%26%20Insert%20Mode%5D
-- Maybe try to add some?

local map = vim.keymap.set

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
map("n", "<leader>ff", "<cmd> Telescope frecency workspace=CWD <CR>", { desc = "find files (frecency)" })

map("n", "<leader><tab>", function()
  require("telescope.builtin").buffers {
    initial_mode = "normal",
  }
end)

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

-- Debugging stuff
map("n", "<leader>db", require("dap").toggle_breakpoint, { desc = "toggle breakpoint" })
map("n", "<leader>dc", require("dap").continue, { desc = "continue" })
