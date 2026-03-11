local function map(keymap, fn, desc)
  vim.keymap.set("n", "<leader>" .. keymap, fn, { desc = "Picker: " .. desc })
end

local picker = require "snacks.picker"

map("gs", picker.git_status, "git status")
map("flb", picker.lsp_symbols, "see buffer LSP symbols")
map("flw", picker.lsp_workspace_symbols, "see workspace LSP symbols")
map("fh", picker.help, "help page")
map("re", picker.registers, "see registers")
map("<tab>", picker.buffers, "show current buffers")
map("fz", picker.lines, "search lines")
map("th", picker.colorschemes, "theme picker")
map("fw", picker.grep, "grep")
map("fg", picker.grep_word, "grep word")
map(":", picker.command_history, "command history")

map("ff", function()
  picker.files { matcher = { frecency = true }, hidden = true }
end, "find files")

map("gl", function()
  picker.git_log { confirm = "close" }
end, "git log")

map("to", function()
  picker.grep_word {
    glob = vim.g.todo_grep_globs,
    regex = true,
    search = "TO" .. "DO:|^\\s*-\\s*\\[\\s*\\]",
  }
end, "search TODOs")

map("gd", function()
  local function get_lines(cmd)
    local result = vim.system(cmd, { text = true }):wait()
    return vim.split(vim.trim(result.stdout), "\n", { trimempty = true, plain = true })
  end

  local compare = "refs/remotes/origin/HEAD"
  local diff_filenames = get_lines { "git", "diff", compare .. "..HEAD", "--name-only" } or {}

  picker {
    title = "Diff against " .. compare .. " (committed content only)",
    items = vim.tbl_map(function(line)
      return { text = line, file = line }
    end, diff_filenames),
    format = "file",
    preview = function(ctx)
      local diff_lines = get_lines { "git", "diff", compare .. "..HEAD", "--", ctx.item.file }
      ctx.preview:set_lines(diff_lines)
      ctx.preview:highlight { ft = "diff" }
    end,
  }
end, "see files modified in this branch")
