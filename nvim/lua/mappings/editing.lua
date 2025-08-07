-- Editing, motions, replacing, etc.
local map = vim.keymap.set

-- Some useful native tricks:
-- gq/gw (formatting) + ap/ip (paragraph motion)
-- g; g,
-- gi
-- g&

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
map("v", "<leader>fr", patterns.find_and_replace_selected, { desc = "find and replace (selected lines)" })

-- TODO: Experimental
map("n", "<leader>frc", patterns.find_and_replace_global_confirm, { desc = "find and replace (global + confirm)" })
map("n", "<leader>/", ":let @/ = expand('<cword>')<cr>:set hlsearch<cr>", { desc = "search word", silent = true })
-- TODO: A bit hard to type but it's going in a good direction (just change? the keymap).
map("x", "<leader>/", require "pattern-tools.auto_hl", { desc = "highlight selection incrementally", silent = true })
map({ "n", "x" }, "<leader>e", patterns.edit_with_macro, { desc = "set as search and start macro", silent = true })
map("n", "<leader>rr", 'v"vy"vp', { desc = "repeat character", noremap = true })
map("n", "<leader>rw", 'viw"vye"vp', { desc = "repeat word", noremap = true })
map("n", "<leader>rW", 'viW"vyE"vp', { desc = "repeat WORD", noremap = true })

-- Move selected text.
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

local wrappers = {
  ['"'] = { '"', '"' },
  ["'"] = { "'", "'" },
  ["`"] = { "`", "`" },
  ["("] = { "(", ")" },
  ["["] = { "[", "]" },
  ["{"] = { "{\n", "\n}" },
}

-- Wrap selected text or word under the cursor.
-- Can then be removed using "tpope/vim-surround"
for key, chars in pairs(wrappers) do
  map("x", "<leader>" .. key, '"zs' .. chars[1] .. "<C-r>z" .. chars[2] .. "<Esc>")
  map("n", "<leader>" .. key, 'viW"zs' .. chars[1] .. "<C-r>z" .. chars[2] .. "<Esc>")
end

map("n", "<leader>!", require "toggle-boolean", { desc = "toggle boolean" })

-- Add undo breakpoints while inserting
local keep = { ".", "!", "?", ";" }
local dont_keep = { ",", ":", "_", "-" }

for _, c in pairs(keep) do
  map("i", c, c .. "<c-g>u")
end

for _, c in pairs(dont_keep) do
  map("i", c, "<c-g>u" .. c)
end
