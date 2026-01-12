local map = vim.keymap.set

map({ "n", "x" }, "<C-j>", "6j")
map({ "n", "x" }, "<C-k>", "6k")

for i = 1, 6, 1 do
  map("n", "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<CR>", { desc = "tab " .. i })
end

map("n", "<leader>b", "<cmd>enew<CR>", { desc = "buffer new" })

map("n", "<c-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "tab prev" })
map("n", "<c-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "tab next" })
map("n", "<leader><c-h>", "<cmd>BufferLineMovePrev<CR>", { desc = "buffer move prev" })
map("n", "<leader><c-l>", "<cmd>BufferLineMoveNext<CR>", { desc = "buffer move next" })

require("buffer-close").listen_closed_buffers()

map("n", "<leader>tx", function()
  local curr_bufnr = vim.api.nvim_get_current_buf()

  -- TODO: What happens with unnamed ones?
  for _, buf in ipairs(require("buffer-close").listed_buffers()) do
    if curr_bufnr ~= buf and vim.bo[buf].modified then
      vim.notify("Some buffers are unsaved", vim.log.levels.WARN)
      return
    end
  end

  vim.cmd "BufferLineCloseOthers"
end, { desc = "close other tabs if none are unsaved" })

map("n", "<leader>x", "<cmd>bd<cr>", { desc = "buffer close" })
map("n", "<leader>X", "<cmd>bd!<cr>", { desc = "buffer close (force)" })
map("n", "<leader>tr", require("buffer-close").reopen, { desc = "tab re-open" })
