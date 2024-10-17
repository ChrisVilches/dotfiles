return {
  "luckasRanarison/tailwind-tools.nvim",
  -- TODO: Should be a different event.
  event = "VeryLazy",
  name = "tailwind-tools",
  build = ":UpdateRemotePlugins",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim", -- optional
    "neovim/nvim-lspconfig", -- optional
  },
  opts = {}, -- your configuration
}
