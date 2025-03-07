local function on_attach()
  local gitsigns = require "gitsigns"
  local map = vim.keymap.set
  map("n", "<leader>ph", gitsigns.preview_hunk, { desc = "Preview hunk" })
  map("n", "<leader>rh", gitsigns.reset_hunk, { desc = "Reset hunk" })
  map("n", "<leader>gb", function()
    gitsigns.blame_line { full = true }
  end, { desc = "Git blame" })

  -- There are more available
  -- map('n', '<leader>hs', gitsigns.stage_hunk)
  -- map('v', '<leader>hs', function() gitsigns.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
  -- map('v', '<leader>hr', function() gitsigns.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
  -- map('n', '<leader>hS', gitsigns.stage_buffer)
  -- map('n', '<leader>hu', gitsigns.undo_stage_hunk)
  -- map('n', '<leader>hR', gitsigns.reset_buffer)
  -- map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
  -- map('n', '<leader>hd', gitsigns.diffthis)
  -- map('n', '<leader>hD', function() gitsigns.diffthis('~') end)
  -- map('n', '<leader>td', gitsigns.toggle_deleted)
end

return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("gitsigns").setup {
      on_attach = on_attach,
    }
  end,
}
