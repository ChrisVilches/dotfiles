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
