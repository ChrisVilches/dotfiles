return {
  {
    "linrongbin16/lsp-progress.nvim",
    config = function()
      require("lsp-progress").setup {}
    end,
  },
  {
    "tpope/vim-surround",
    event = "BufEnter",
  },
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      require("notify").setup {
        merge_duplicates = false,
        background_colour = "#000000",
      }
    end,
  },
  {
    -- This plugins adds gb/gbc bindings to comment as blocks (e.g. in C++ it uses /* */ instead of //)
    -- Can also be integrated with TreeSitter.
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = true,
  },
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
  },
  -- TODO: Try in the future:
  -- Friendly snippets (currently I only use it for Lua because it's the default, but
  -- do it for other languages as well)
  -- https://github.com/folke/trouble.nvim
  -- https://github.com/mbbill/undotree
  -- https://github.com/gbprod/substitute.nvim
  -- https://github.com/jake-stewart/multicursor.nvim
  -- https://github.com/nvim-telescope/telescope-smart-history.nvim
}
