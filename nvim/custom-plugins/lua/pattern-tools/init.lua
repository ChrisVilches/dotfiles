-- TODO: This should be tested with some alternative searching options. This is what ChatGPT said:
-- Yes, when you press n in Vim while searching, the cursor is placed on the first character of the next match. This is the default behavior for both / (forward search) and ? (backward search).
-- However, there are some cases where the cursor might not be exactly where you expect:
-- If you use set incsearch, the match is highlighted as you type, but the cursor stays at its original position until you press Enter.
-- If you use set nowrapscan, Vim won’t wrap around the file when reaching the last match.
-- If you use \zs in your search pattern, the match position can be altered. For example, /foo\zsbar will match foobar, but the cursor will be placed at b in bar instead of f in foo.

local M = {}

local function trim(s)
  return s:match "^%s*(.-)%s*$"
end

local function use_word()
  return vim.api.nvim_get_mode().mode == "n"
end

-- Refer to "very nomagic" or \V in the help documentation to understand which characters need to be escaped.
local function clean(text)
  local special_chars_attempt = [[\/]]

  text = vim.fn.escape(text, special_chars_attempt)
  text = trim(text)
  text = text:gsub("\n", [[\n]])
  return text
end

-- Warning: This function may unexpectedly change the mode. Ensure to store the initial mode before invoking it.
function M.search_text()
  if use_word() then
    vim.cmd [[let @/ = expand('<cword>')]]
  else
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local very_nomagic = [[\V]]
    vim.api.nvim_command 'silent normal! "vy'

    -- Restore the cursor position after yanking, as yanking changes it.
    -- Known issue: If the selection is too long, causing the cursor to move away from the first character,
    -- the highlight might not be displayed. This is likely due to a Neovim performance optimization.
    vim.api.nvim_win_set_cursor(0, cursor_pos)
    vim.fn.setreg("/", very_nomagic .. clean(vim.fn.getreg "v"))
  end

  vim.cmd [[set hlsearch]]
end

local function feed_keys(keys)
  keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.fn.feedkeys(keys, "n")
end

function M.find_and_replace_line()
  feed_keys [[:s///g<Left><Left><Left>]]
end

function M.find_and_replace_global()
  feed_keys [[:%s///g<Left><Left><Left>]]
end

function M.find_and_replace_global_confirm()
  feed_keys [[:%s///gc<Left><Left><Left><Left>]]
end

-- TODO: Test
function M.edit_with_macro()
  local move_to_first_character = use_word() and "#*" or "nN"

  M.search_text()

  vim.cmd("normal! " .. move_to_first_character)
  vim.cmd [[normal! qa]]
end

return M
