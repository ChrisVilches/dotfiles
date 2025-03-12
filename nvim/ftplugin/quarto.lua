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

-- TODO: It's necessary to wrap the function calls so that this script doesn't initialize the Quarto plugin.
-- Instead, Quarto has to be initialized due to the format event.
-- This is because if this script loads Quarto, it won't get initialized properly (some highlights won't be
-- rendered, etc).
-- I wish I could fix it so that we don't have to think so much about why this is going on (it should simply work).
map("n", "<localleader>qr", function()
  require("quarto.runner").run_cell()
end, opts "run cell")

map("n", "<localleader>qR", function()
  require("quarto.runner").run_all()
end, opts "run all cells")

map("n", "<localleader>qp", function()
  insert_code_chunk "python"
end, opts "create Python cell")
