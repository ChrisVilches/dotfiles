local M = {}

local util = require "pattern-tools.util"

local function use_word()
  return vim.api.nvim_get_mode().mode == "n"
end

function M.find_and_replace_line()
  util.feed_keys [[:s///g<Left><Left><Left>]]
end

function M.find_and_replace_global()
  util.feed_keys [[:%s///g<Left><Left><Left>]]
end

function M.find_and_replace_global_confirm()
  util.feed_keys [[:%s///gc<Left><Left><Left><Left>]]
end

-- TODO: Test and practice
function M.edit_with_macro()
  local move_to_first_character = use_word() and "#*" or "nN"
  local text

  if use_word() then
    text = vim.fn.expand "<cword>"
  else
    text = util.get_escaped_selection()
    util.go_to_normal_mode()
  end

  vim.fn.setreg("/", text)
  vim.cmd [[set hlsearch]]

  vim.cmd("normal! " .. move_to_first_character)
  vim.cmd("normal! q" .. require("pattern-tools.config").opts.macro_reg)
end

return M
