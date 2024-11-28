local map = vim.keymap.set

map("n", "<C-l>", function()
  if require("utils").is_buffer_in_bufferline() then
    vim.cmd "BufferLineCycleNext"
  else
    vim.cmd "wincmd l"
  end
end, { desc = "navigate right (smart)" })

map("n", "<C-h>", function()
  if require("utils").is_buffer_in_bufferline() then
    vim.cmd "BufferLineCyclePrev"
  else
    vim.cmd "wincmd h"
  end
end, { desc = "navigate left (smart)" })

map({ "n", "x" }, "<C-j>", "6j")
map({ "n", "x" }, "<C-k>", "6k")

for i = 1, 6, 1 do
  map("n", "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<CR>", { desc = "tab " .. i })
end

map("n", "<leader>b", "<cmd>enew<CR>", { desc = "buffer new" })
map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })

map("n", "<leader><C-h>", "<cmd>BufferLineMovePrev<CR>", { desc = "buffer move prev" })
map("n", "<leader><C-l>", "<cmd>BufferLineMoveNext<CR>", { desc = "buffer move next" })

map(
  "n",
  "<leader>tx",
  require("utils").close_other_except_unsaved,
  { desc = "close all tabs except current and unsaved" }
)

-- TODO: This should be implemented as a stack (pushing latest closed tabs, and popping when I re-open them)
-- The behavior is a bit weird if I try to re-open the same file multiple times or if it's already opened.
-- But this is VERY low priority, so maybe triage.
-- Actually it's pretty useful when I want to re-open several closed tabs in the order I closed them, so maybe
-- do implement the stack based approach.

local closed_files = require("stack").Stack()

local close_buffer_wrapper = function(force)
  local name = vim.api.nvim_buf_get_name(0)
  local closed = require("utils").close_buffer { force = force }

  if closed then
    closed_files:push(name)
  end
end

map("n", "<leader>x", function()
  close_buffer_wrapper(false)
end, { desc = "buffer close" })

map("n", "<leader>X", function()
  close_buffer_wrapper(true)
end, { desc = "buffer close (force)" })

map("n", "<leader>tr", function()
  if closed_files:is_empty() then
    -- TODO: This error appears even if I have closed some files
    vim.api.nvim_err_writeln "No files to re-open"
    return
  end

  local file_path = closed_files:pop()

  if vim.loop.fs_stat(file_path) then
    vim.cmd("edit " .. vim.fn.fnameescape(file_path))
  else
    vim.api.nvim_err_writeln("Cannot re-open file: " .. file_path)
  end
end, { desc = "tab re-open" })
