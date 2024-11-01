local map = vim.keymap.set

-- TODO: Needs testing and see if it works for me.
--
-- These bindings either change tabs, or move to a different window if it's focusing the file explorer tree
-- or a help window, etc.
-- It works mostly OK. It only stops working as expected when the code window is closed, and only the file
-- explorer is remaining (in which case the buttons don't change to the code window, because it doesn't exist).
-- But these cases are a relatively rare.
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

map("n", "<C-j>", "<C-w>j", { desc = "navigate down" })
map("n", "<C-k>", "<C-w>k", { desc = "navigate up" })

-- TODO: These clash with the ones above. I doing the "smart navigation" using hjkl,
-- so using different keys for moving tabs.
-- map("n", "<C-k>", "<cmd>BufferLineMoveNext<CR>", { desc = "buffer move next" })
-- map("n", "<C-j>", "<cmd>BufferLineMovePrev<CR>", { desc = "buffer move prev" })

map("n", "<leader>tx", "<cmd> BufferLineCloseOthers <CR>", { desc = "close all tabs except current and unsaved" })
