-- TODO: Not sure how to use this plugin properly yet.
-- The next time I do a frontend project, learn this properly.
-- Check the documentation to see more tips and improvements
-- (e.g. integration with other plugins, etc).
return {
  "luckasRanarison/tailwind-tools.nvim",
  -- event = "FileType tsx,html,php",
  event = "VeryLazy",
  -- TODO: Disabled for now, because it throws this error.
  -- The `require('lspconfig')` "framework" is deprecated, use vim.lsp.config (see :help lspconfig-nvim-0.11) instead.
  -- Feature will be removed in nvim-lspconfig v3.0.0
  enabled = false,
  name = "tailwind-tools",
  build = ":UpdateRemotePlugins",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim", -- optional
    "neovim/nvim-lspconfig", -- optional
  },
  opts = {}, -- your configuration
}
