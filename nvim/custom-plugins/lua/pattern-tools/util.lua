local M = {}

local function trim(s)
  return s:match "^%s*(.-)%s*$"
end

function M.get_selection()
  local opts = { type = vim.fn.mode() }
  local lines = vim.fn.getregion(vim.fn.getpos "v", vim.fn.getpos ".", opts)
  local text = table.concat(lines, "\n")
  return text
end

-- Refer to "very nomagic" or \V in the help documentation to understand which characters need to be escaped.
function M.convert_very_nomagic(text)
  local special_chars = [[\/]]
  local very_nomagic = [[\V]]

  text = vim.fn.escape(text, special_chars)
  text = trim(text)
  text = text:gsub("\n", [[\n]])
  return very_nomagic .. text
end

function M.go_to_normal_mode()
  vim.cmd [[exe "normal \<esc>"]]
end

function M.feed_keys(keys)
  keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.fn.feedkeys(keys, "n")
end

return M
