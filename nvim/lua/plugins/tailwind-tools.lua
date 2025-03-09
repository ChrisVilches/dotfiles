-- TODO: Not sure how to use this plugin properly yet.
-- The next time I do a frontend project, learn this properly.
-- Check the documentation to see more tips and improvements
-- (e.g. integration with other plugins, etc).
return {
  "luckasRanarison/tailwind-tools.nvim",
  event = "FileType html,php",
  name = "tailwind-tools",
  build = ":UpdateRemotePlugins",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim", -- optional
    "neovim/nvim-lspconfig", -- optional
  },
  opts = {}, -- your configuration
}
