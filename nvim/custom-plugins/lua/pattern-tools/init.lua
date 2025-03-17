local M = {}

local function use_word()
  return vim.api.nvim_get_mode().mode == "n"
end

-- This function also switches to normal mode.
function M.search_text()
  if use_word() then
    vim.cmd [[let @/ = expand('<cword>')]]
  else
    local text = require("pattern-tools.util").get_selection()
    vim.fn.setreg("/", require("pattern-tools.util").convert_very_nomagic(text))
  end

  require("pattern-tools.util").go_to_normal_mode()
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

-- TODO: Test and practice
function M.edit_with_macro()
  local move_to_first_character = use_word() and "#*" or "nN"

  M.search_text()

  vim.cmd("normal! " .. move_to_first_character)
  vim.cmd [[normal! qa]]
end

return M
