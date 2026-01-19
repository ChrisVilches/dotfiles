return {
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
    "stevearc/dressing.nvim",
    event = "VeryLazy",
  },
  {
    "OXY2DEV/markview.nvim",
    --   Alternative:
    --   "MeanderingProgrammer/render-markdown.nvim",
    branch = "main",
    ft = { "markdown" },
    opts = {
      -- preview = {
      --   filetypes = { "markdown", "Avante" },
      --   ignore_buftypes = {},
      -- },
      max_length = 99999,
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },
  -- TODO: Try in the future:
  -- Friendly snippets (currently I only use it for Lua because it's the default, but
  -- do it for other languages as well)
  -- https://github.com/folke/trouble.nvim
  -- https://github.com/mbbill/undotree
  -- https://github.com/gbprod/substitute.nvim
  -- https://github.com/nvim-telescope/telescope-smart-history.nvim
}
