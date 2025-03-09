-- Editing, motions, replacing, etc.
local map = vim.keymap.set

-- This overrides a native neovim keyboard shortcut that inserts a previously inserted text,
-- but I never used it, so it's alright. I prefer having the same setup as in a terminal so I can
-- get used to doing that motion both in Neovim and the terminal.
map("i", "<C-e>", "<End>", { desc = "move end of line" })
map("i", "<C-a>", "<ESC>I", { desc = "move beginning of line" })
map("i", "<C-d>", "<ESC><Right>ce")

-- Exit parentheses while editing.
map("i", "<C-l>", "<Left><c-o>:call search('}\\|)\\|]\\|>\\|\"', 'W')<cr><Right>", { silent = true })

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
map("x", "<leader>(", '"zs(<C-r>z)<Esc>')
map("x", "<leader>{", '"zs{\n<C-r>z\n}<Esc>')

-- Wrap selected text or the word under the cursor with quotes
map("x", '<leader>"', '"zs"<C-r>z"<Esc>')
map("x", "<leader>'", "\"zs'<C-r>z'<Esc>")
map("n", '<leader>"', 'viW"zs"<C-r>z"<Esc>')
map("n", "<leader>'", "viW\"zs'<C-r>z'<Esc>")

local function toggle_boolean()
  local utils = require "utils"
  -- This is a hack to avoid toggling booleans in these situations:
  -- some_var=True (python) when the cursor is on the =.
  -- [true, false, false] when the cursor is on a comma.
  if not utils.is_char_alpha(utils.current_char_under_cursor()) then
    return
  end

  local current_word = vim.fn.expand "<cword>"
  local toggle_map = {
    ["false"] = "true",
    ["true"] = "false",
    ["False"] = "True",
    ["True"] = "False",
  }
  local replacement = toggle_map[current_word]

  if replacement then
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd("normal! ciw" .. replacement)
    vim.api.nvim_win_set_cursor(0, cursor_pos)
  end
end

map("n", "<leader>!", toggle_boolean, { desc = "toggle boolean" })
