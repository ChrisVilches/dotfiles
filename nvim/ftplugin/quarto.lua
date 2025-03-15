local buf = vim.api.nvim_get_current_buf()

-- Retrieves positions of all code blocks in the current buffer
local function get_cell_positions()
  local parsername = "markdown"
  local parser = vim.treesitter.get_parser(buf, parsername)
  local cell_query = [[(fenced_code_block)@codeblock]]
  local query = vim.treesitter.query.parse(parsername, cell_query)
  local tree = parser:parse()
  local root = tree[1]:root()
  local res = {}
  for _, match, _ in query:iter_matches(root, buf, 0, -1, { all = true }) do
    for _, nodes in pairs(match) do
      for _, node in ipairs(nodes) do
        local start_line, _, end_line, _ = node:range()
        table.insert(res, { start_line, end_line })
      end
    end
  end
  table.sort(res, function(a, b)
    return a[1] < b[1]
  end)
  return res
end

local function go_to_next_codeblock()
  local curr = vim.fn.line "."
  for _, cell in ipairs(get_cell_positions()) do
    if curr < cell[1] + 2 then
      vim.api.nvim_win_set_cursor(0, { cell[1] + 2, 0 })
      return
    end
  end
end

local function go_to_prev_codeblock()
  local curr = vim.fn.line "."
  local found = nil
  for _, cell in ipairs(get_cell_positions()) do
    if cell[2] >= curr then
      break
    end
    found = cell[1] + 2
  end
  if found ~= nil then
    vim.api.nvim_win_set_cursor(0, { found, 0 })
  end
end

-- Why "vim.schedule" is necessary:
-- The expected event when lazy loading the Quarto plugin should be:
-- ● quarto-nvim 10.76ms  quarto
-- (instead of this script triggering the lazy load)
-- If this script is the first one to trigger the Quarto plugin load, it won't load
-- properly (e.g. code won't be highlighted).
vim.schedule(function()
  local map = vim.keymap.set
  local function opts(desc)
    return { desc = "quarto: " .. desc, buffer = buf, noremap = true, silent = true, nowait = true }
  end
  map("n", "<CR>", require("quarto.runner").run_cell, opts "run cell")
  map("n", "<localleader>R", require("quarto.runner").run_all, opts "run all cells")
  map("n", "<localleader>a", "<CMD>QuartoActivate<CR>", opts "activate")
  map("n", "[", go_to_prev_codeblock, opts "go to prev block")
  map("n", "]", go_to_next_codeblock, opts "go to next block")
  map("n", "<localleader>p", "i```{python}\n\n```<Up>", opts "create Python cell")
end)

-- Autocommand to activate LSP for new files because Otter cannot detect code blocks in empty files initially.
vim.api.nvim_create_autocmd({ "BufWrite" }, {
  group = vim.api.nvim_create_augroup("QuartoAutoActivate", { clear = true }),
  buffer = buf,
  callback = function()
    vim.cmd "QuartoActivate"
  end,
})

-- LSP mappings are not automatically attached to Quarto files. This autocommand ensures
-- that LSP mappings are set up correctly when the LSP attaches to a buffer.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("QuartoLspAttach", { clear = true }),
  buffer = buf,
  callback = function(event)
    require "mappings.lsp"(event.buf)
  end,
})

local ns = vim.api.nvim_create_namespace "QuartoHighlight"
vim.api.nvim_set_hl(ns, "@markup.codecell", { link = "CursorLine" })
vim.api.nvim_set_hl(ns, "@markup.codecellborder", { link = "CursorColumn" })

local function clear_all_highlights()
  local all = vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {})
  for _, mark in ipairs(all) do
    vim.api.nvim_buf_del_extmark(buf, ns, mark[1])
  end
end

local function highlight_range(from, to)
  for i = from, to do
    local hl = (i == from or i == to) and "@markup.codecellborder" or "@markup.codecell"

    vim.api.nvim_buf_set_extmark(buf, ns, i, 0, { hl_eol = true, line_hl_group = hl })
  end
end

local function highlight_cells()
  clear_all_highlights()

  vim.api.nvim_win_set_hl_ns(0, ns)
  for _, cell in ipairs(get_cell_positions()) do
    pcall(highlight_range, cell[1], cell[2] - 1)
  end
end

vim.api.nvim_create_autocmd({ "ModeChanged", "BufWrite", "BufEnter", "WinEnter" }, {
  group = vim.api.nvim_create_augroup("QuartoCellHighlight", { clear = true }),
  buffer = buf,
  callback = highlight_cells,
})
