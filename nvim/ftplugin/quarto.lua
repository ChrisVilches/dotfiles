local buf = vim.api.nvim_get_current_buf()

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
  map("n", "<CR>", ":QuartoSend<CR>", opts "run cell")
  map("n", "<localleader>R", ":QuartoSendAll<CR>", opts "run all cells")
  map("n", "<localleader>a", ":QuartoActivate<CR>", opts "activate")
  map("n", "[", ":TSTextobjectGotoPreviousStart @block.inner<CR>", opts "go to prev block")
  map("n", "]", ":TSTextobjectGotoNextStart @block.inner<CR>", opts "go to next block")
end)

-- Autocommand to activate LSP for new files because Otter cannot detect code blocks in empty files initially.
vim.api.nvim_create_autocmd({ "BufWrite" }, {
  group = vim.api.nvim_create_augroup("QuartoAutoActivate", { clear = true }),
  buffer = buf,
  callback = function()
    vim.cmd "QuartoActivate"
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
  return res
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
