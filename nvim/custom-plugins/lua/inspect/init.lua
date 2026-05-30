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

local function missing_parsers(parser, buf)
  local seen = {}
  local function traverse(p)
    local root_lang = p:lang()
    local ok, query = pcall(vim.treesitter.query.get, root_lang, "injections")
    if ok and query then
      local trees = p:trees()
      if trees and #trees > 0 then
        local root = trees[1]:root()
        for capture_id, node, metadata in query:iter_captures(root, buf, 0, -1) do
          local capture_name = query.captures[capture_id]
          local lang = nil

          if capture_name == "injection.language" then
            lang = vim.treesitter.get_node_text(node, buf)
          elseif metadata and metadata["injection.language"] then
            lang = metadata["injection.language"]
          end

          if lang then
            lang = vim.treesitter.language.get_lang(lang) or lang
            local ok2, _ = pcall(vim.treesitter.language.inspect, lang)
            if not ok2 and not seen[lang] then
              seen[lang] = true
            end
          end
        end
      end
    end
    for _, child in pairs(p:children()) do
      traverse(child)
    end
  end
  traverse(parser)
  local result = vim.tbl_keys(seen)
  table.sort(result)
  return result
end

-- Can be reproduced by removing the highlights.scm file.
-- e.g. in ~/.local/share/nvim/site/queries/mermaid
local function has_highlight_queries(lang)
  local ok, query = pcall(vim.treesitter.query.get, lang, "highlights")
  return ok and query ~= nil
end

local function add_parser_tree(lines, parser, prefix)
  prefix = prefix or "  "
  local children = parser:children() -- cache once
  local keys = vim.tbl_keys(children)
  table.sort(keys)
  for i, lang in ipairs(keys) do
    local is_last = i == #keys
    local branch = is_last and "└─ " or "├─ "
    local next_prefix = prefix .. (is_last and "   " or "│  ")
    local suffix = has_highlight_queries(lang) and "" or " (no highlights)"
    table.insert(lines, string.format("%s%s%s%s", prefix, branch, lang, suffix))
    add_parser_tree(lines, children[lang], next_prefix) -- use cached table
  end
end

function M.inspect()
  local current = vim.api.nvim_get_current_buf()
  local lines = {}

  local function append_buf_info(buf)
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":.")
    local ft = vim.bo[buf].filetype
    local bt = vim.bo[buf].buftype
    local loaded = vim.api.nvim_buf_is_loaded(buf) and "loaded" or "unloaded"
    local listed = vim.bo[buf].buflisted and "listed" or "unlisted"
    local parser = vim.treesitter.get_parser(buf)
    local ts_status = treesitter_status(buf)

    table.insert(lines, string.format("Buffer #%d  [%s, %s]", buf, loaded, listed))
    table.insert(lines, string.format("  Name:        %s", name ~= "" and name or "[No Name]"))
    table.insert(lines, string.format("  Filetype:    %s", ft ~= "" and ft or "none"))
    table.insert(lines, string.format("  Buftype:     %s", bt ~= "" and bt or "normal"))
    table.insert(lines, string.format("  LSP:         %s", lsp_status(buf)))
    table.insert(lines, string.format("  Treesitter:  %s", ts_status))

    if parser then
      local root_lang = parser:lang()
      local root_suffix = has_highlight_queries(root_lang) and "" or " (no highlights)"
      table.insert(lines, string.format("  %s%s", root_lang, root_suffix))
      add_parser_tree(lines, parser)
      for _, lang in ipairs(missing_parsers(parser, buf)) do
        table.insert(lines, string.format("  ! %s (not installed)", lang))
      end
    end

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
