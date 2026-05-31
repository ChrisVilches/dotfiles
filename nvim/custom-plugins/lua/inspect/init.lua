local M = {}

-- About parser:parse(true):
-- Force a full recursive parse of the LanguageTree, including injections.
-- According to the parse() docs, this updates the parser's cached internal
-- state, so we do not need to use the returned trees directly. A single
-- parse(true) on the root parser is sufficient; without it, some injected
-- parsers may not be discovered and therefore won't appear in reports.

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

  local function record(lang)
    if not lang then
      return
    end

    lang = vim.treesitter.language.get_lang(lang) or lang

    local installed = pcall(vim.treesitter.language.inspect, lang)

    if not installed then
      seen[lang] = true
    end
  end

  local function traverse(p)
    local root_lang = p:lang()

    local ok, query = pcall(vim.treesitter.query.get, root_lang, "injections")

    if ok and query then
      for _, tree in ipairs(p:trees()) do
        local root = tree:root()

        for _, match, metadata in query:iter_matches(root, buf, 0, -1) do
          -- Match-level language:
          record(metadata and metadata["injection.language"])

          -- Capture-level languages:
          for capture_id, nodes in pairs(match) do
            local capture_name = query.captures[capture_id]

            if capture_name == "injection.language" then
              local node = nodes[1]
              if node then
                record(vim.treesitter.get_node_text(node, buf))
              end
            end

            local capture_meta = metadata and metadata[capture_id]

            if capture_meta then
              record(capture_meta["injection.language"])
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

local function all_parsers_have_highlights(parser)
  if not has_highlight_queries(parser:lang()) then
    return false
  end
  for _, child in pairs(parser:children()) do
    if not all_parsers_have_highlights(child) then
      return false
    end
  end
  return true
end

local function highlights_active(buf)
  return vim.treesitter.highlighter.active[buf]
end

local function add_parser_tree(lines, parser, buf, display_prefix, is_root, child_indent)
  local lang = parser:lang()
  local suffix = ""
  if is_root and not highlights_active(buf) then
    suffix = " (highlights disabled)"
  elseif not has_highlight_queries(lang) then
    suffix = " (no highlights)"
  end

  table.insert(lines, string.format("%s%s%s", display_prefix, lang, suffix))

  child_indent = child_indent or string.rep(" ", #display_prefix)
  local children = parser:children()
  local keys = vim.tbl_keys(children)
  table.sort(keys)
  for i, child_lang in ipairs(keys) do
    local is_last = i == #keys
    local branch = is_last and "└─ " or "├─ "
    local child_display = child_indent .. branch
    local child_next_indent = child_indent .. (is_last and "   " or "│  ")
    add_parser_tree(lines, children[child_lang], buf, child_display, false, child_next_indent)
  end
end

function M.treesitter_ok(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not highlights_active(buf) then
    return false
  end
  local parser = vim.treesitter.get_parser(buf)
  if not parser then
    return false
  end
  parser:parse(true)

  return all_parsers_have_highlights(parser) and #missing_parsers(parser, buf) == 0
end

local function get_treesitter_display(buf)
  local parser = vim.treesitter.get_parser(buf)
  if not parser then
    return nil
  end

  local lines = {}
  parser:parse(true)

  local tree_prefix = "  Treesitter:  "
  add_parser_tree(lines, parser, buf, tree_prefix, true)

  local prefix = string.rep(" ", #tree_prefix)
  for _, lang in ipairs(missing_parsers(parser, buf)) do
    table.insert(lines, string.format("%s! %s (not installed)", prefix, lang))
  end

  return lines
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
    local indentexpr = vim.bo[buf].indentexpr

    table.insert(lines, string.format("Buffer #%d  [%s, %s]", buf, loaded, listed))
    table.insert(lines, string.format("  Name:        %s", name ~= "" and name or "[No Name]"))
    table.insert(lines, string.format("  Filetype:    %s", ft ~= "" and ft or "none"))
    table.insert(lines, string.format("  Buftype:     %s", bt ~= "" and bt or "normal"))
    table.insert(lines, string.format("  Indent:      %s", indentexpr ~= "" and indentexpr or "none"))
    table.insert(lines, string.format("  LSP:         %s", lsp_status(buf)))

    for _, line in ipairs(get_treesitter_display(buf) or { "  Treesitter:  none" }) do
      table.insert(lines, line)
    end

    table.insert(lines, "")
  end

  append_buf_info(current)

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current then
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
