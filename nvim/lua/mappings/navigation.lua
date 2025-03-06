local map = vim.keymap.set

-- Be careful if you add dot (.) since it matches any character (must escape it somehow).
local find_symbols = { "{", "}", "\\[", "\\]", "(", ")", "," }
local pattern = table.concat(find_symbols, "\\|")

-- TODO: I don't really use these... I ended up preferring vanilla Vim motions (which is a good thing IMO).
-- remove these?? or at least comment them out to archive them for later usage if I need them.
map({ "n", "v" }, "<C-h>", function()
  vim.cmd(":call search('" .. pattern .. "', 'Wb')")
end, { desc = "smart move (left)", silent = true })

map({ "n", "v" }, "<C-l>", function()
  vim.cmd(":call search('" .. pattern .. "', 'W')")
end, { desc = "smart move (right)", silent = true })

map({ "n", "x" }, "<C-j>", "6j")
map({ "n", "x" }, "<C-k>", "6k")

for i = 1, 6, 1 do
  map("n", "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<CR>", { desc = "tab " .. i })
end

map("n", "<leader>b", "<cmd>enew<CR>", { desc = "buffer new" })
map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })

map("n", "<leader>h", "<cmd>BufferLineCyclePrev<cr>", { desc = "tab prev" })
map("n", "<leader>l", "<cmd>BufferLineCycleNext<cr>", { desc = "tab next" })
map("n", "<leader><C-h>", "<cmd>BufferLineMovePrev<CR>", { desc = "buffer move prev" })
map("n", "<leader><C-l>", "<cmd>BufferLineMoveNext<CR>", { desc = "buffer move next" })

map(
  "n",
  "<leader>tx",
  require("utils").close_other_except_unsaved,
  { desc = "close all tabs except current and unsaved" }
)

local closed_files = require("stack").Stack:new()

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
