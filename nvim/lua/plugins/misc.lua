return {
  {
    "linrongbin16/lsp-progress.nvim",
    config = function()
      require("lsp-progress").setup {}
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
  -- https://github.com/folke/noice.nvim
  -- https://github.com/gbprod/substitute.nvim
  --
  -- TODO: Try installing Quarto, but first make sure it works on the kickstarter
  -- just run it like this to test it out:
  -- NVIM_APPNAME=quarto-nvim-kickstarter nvim
  -- Also, watch this playlist related to Quarto on Neovim.
  -- I still need to learn how to re-run individual cells! That seems very important and
  -- I haven't been able to get it yet.
  -- A coffee with quarto and neovim (parts 1 ~ 7)
  -- https://www.youtube.com/watch?v=Lc_kMYVIS5I&list=PLabWm-zCaD1axcMGvf7wFxJz8FZmyHSJ7&index=2&ab_channel=JannikBuhr
}
