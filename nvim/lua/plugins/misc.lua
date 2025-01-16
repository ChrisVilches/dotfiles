return {
  {
    "linrongbin16/lsp-progress.nvim",
    lazy = false,
    config = function()
      require("lsp-progress").setup()
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = true,
  },
  {
    "tpope/vim-surround",
    event = "BufEnter",
  },
  {
    "mg979/vim-visual-multi",
    event = "BufEnter",
  },
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      require("notify").setup {
        background_colour = "#000000",
      }
    end,
  },

  -- TODO: Try in the future:
  -- Friendly snippets (currently I only use it for Lua because it's the default, but
  -- do it for other languages as well)
  -- https://github.com/folke/trouble.nvim
  -- https://github.com/mbbill/undotree
  -- https://github.com/folke/noice.nvim
  -- https://github.com/gbprod/substitute.nvim
}
