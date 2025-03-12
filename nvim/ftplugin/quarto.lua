local map = vim.keymap.set

local function is_code_chunk()
  local current, _ = require("otter.keeper").get_current_language_context()
  if current then
    return true
  else
    return false
  end
end

local function insert_code_chunk(lang)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", true)
  local keys
  if is_code_chunk() then
    keys = [[o```<cr><cr>```{]] .. lang .. [[}<esc>o]]
  else
    keys = [[o```{]] .. lang .. [[}<cr>```<esc>O]]
  end
  keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(keys, "n", false)
end

local function opts(desc)
  return { desc = "quarto: " .. desc, buffer = 0, noremap = true, silent = true, nowait = true }
end

map("n", "<localleader>qr", require("quarto.runner").run_cell, opts "run cell")
map("n", "<localleader>qR", require("quarto.runner").run_all, opts "run all cells")

map("n", "<localleader>qp", function()
  insert_code_chunk "python"
end, opts "create Python cell")
