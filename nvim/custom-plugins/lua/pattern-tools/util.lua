local M = {}

local function trim(s)
  return s:match "^%s*(.-)%s*$"
end

local function get_selection()
  local opts = { type = vim.fn.mode() }
  local lines = vim.fn.getregion(vim.fn.getpos "v", vim.fn.getpos ".", opts)
  local text = table.concat(lines, "\n")
  return text
end

-- Refer to "very nomagic" or \V in the help documentation to understand which characters need to be escaped.
local function convert_very_nomagic(text)
  local special_chars = [[\/]]
  local very_nomagic = [[\V]]

  text = vim.fn.escape(text, special_chars)
  text = trim(text)
  text = text:gsub("\n", [[\n]])
  return very_nomagic .. text
end

function M.get_escaped_selection()
  return convert_very_nomagic(get_selection())
end

function M.feed_keys(keys)
  keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.fn.feedkeys(keys, "n")
end

function M.mode_is_visual()
  local mode = vim.fn.mode()
  return mode == "v" or mode == "V" or mode == ""
end

return M
