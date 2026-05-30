local M = {}

local function treesitter_status(buf)
  if vim.bo[buf].filetype == "" then
    return "N/A (no filetype)"
  end

  if vim.treesitter.highlighter.active[buf] then
    return "active"
  end

  if vim.treesitter.get_parser(buf) then
    return "parser loaded, not highlighting"
  end

  return "inactive"
end

local function lsp_status(buf)
  local clients = vim.lsp.get_clients { bufnr = buf }
  local names = {}
  for _, client in ipairs(clients) do
    if client and client.name ~= "" then
      table.insert(names, client.name)
    end
  end
  return #names > 0 and table.concat(names, ", ") or "none"
end

function M.inspect()
  local current = vim.api.nvim_get_current_buf()
  local lines = {}

  local function append_buf_info(buf)
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end
    local name = vim.api.nvim_buf_get_name(buf)
    local ft = vim.bo[buf].filetype
    local bt = vim.bo[buf].buftype
    local loaded = vim.api.nvim_buf_is_loaded(buf) and "loaded" or "unloaded"

    table.insert(lines, string.format("Buffer #%d  [%s]", buf, loaded))
    table.insert(lines, string.format("  Name:        %s", name ~= "" and name or "[No Name]"))
    table.insert(lines, string.format("  Filetype:    %s", ft ~= "" and ft or "none"))
    table.insert(lines, string.format("  Buftype:     %s", bt ~= "" and bt or "normal"))
    table.insert(lines, string.format("  Treesitter:  %s", treesitter_status(buf)))
    table.insert(lines, string.format("  LSP:         %s", lsp_status(buf)))
    table.insert(lines, "")
  end

  if vim.api.nvim_buf_is_valid(current) then
    append_buf_info(current)
  end

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.api.nvim_buf_is_valid(buf) then
      append_buf_info(buf)
    end
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].swapfile = false

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false

  local width = math.min(100, vim.o.columns - 4)
  local height = math.min(#lines, vim.o.lines - 4)
  vim.api.nvim_open_win(bufnr, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    border = "single",
    title = " Buffer Inspector ",
    title_pos = "center",
  })


  for _, k in pairs({ "q", "<esc>" }) do
    vim.keymap.set("n", k, "<cmd>close<cr>", { buffer = bufnr, silent = true, nowait = true })
  end
end

return M
