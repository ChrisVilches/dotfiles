local map = vim.keymap.set

local function insert_code_chunk(lang)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", true)
  local keys = [[o```{]] .. lang .. [[}<cr>```<esc>O]]
  keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(keys, "n", false)
end

local function opts(desc)
  return { desc = "quarto: " .. desc, buffer = 0, noremap = true, silent = true, nowait = true }
end

-- Why "vim.schedule" is necessary:
-- The expected event when lazy loading the Quarto plugin should be:
-- ● quarto-nvim 10.76ms  quarto
-- (instead of this script triggering the lazy load)
-- If this script is the first one to trigger the Quarto plugin load, it won't load
-- properly (e.g. code won't be highlighted).
vim.schedule(function()
  map("n", "<localleader>qr", require("quarto.runner").run_cell, opts "run cell")
  map("n", "<localleader>qR", require("quarto.runner").run_all, opts "run all cells")

  map("n", "<localleader>qp", function()
    insert_code_chunk "python"
  end, opts "create Python cell")
end)
