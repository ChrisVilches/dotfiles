-- TODO: Move all plugins to an individual file like how I did with treesitter,
-- but do this after I commit some previous changes. I want to know what is a config change
-- and what is simply a file move.
-- Then also restructure the folders to remove unused or redundant nesting, etc.
-- TODO: Telescope, sort files by most accessed????
-- check this out: https://www.youtube.com/watch?v=Qr-vX51gB8g
-- (video title: Sort files in telescope by showing the most accessed files first)
return {
  {
    "tpope/vim-surround",
    event = "VeryLazy",
  },
  {
    "mg979/vim-visual-multi",
    event = "VeryLazy",
  },
  -- TODO: This should be a Mason formatter or something like that.
  -- {
  --   "slim-template/vim-slim",
  --   ft = "slim",
  -- },
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    config = function()
      require "configs.conform"
    end,
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
    -- TODO: ruby activates linting but the notifying thingy starts appearing
    -- on tabs for any other language as well. It should only work for the specified
    -- formats, not for other formats. How to reproduce: There's a difference before and
    -- after opening a Ruby buffer.
    "mfussenegger/nvim-lint",
    ft = { "ruby" },
    config = function()
      require "configs.nvim-lint"
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },
  {
    -- TODO: It's a bit hard to see what is being required by which plugin, and
    --       to which category they belong (LSP, linter, formatter), so make sure to understand all that.
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "clangd",
        "lua-language-server",
        "stylua",
        "html-lsp",
        "css-lsp",
        "gopls",
        "prettier",
        "autopep8",
        "pyright",
        "rust",
      },
    },
  },
  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-tree.lua",
    },
    event = "VeryLazy",
    config = function()
      require("lsp-file-operations").setup()
    end,
  },

  -- TODO: Try in the future:
  -- https://github.com/folke/trouble.nvim
  -- https://github.com/mbbill/undotree
  -- https://github.com/tpope/vim-fugitive
  -- https://github.com/folke/noice.nvim
  -- This one is for stopping using tabs
  -- https://github.com/j-morano/buffer_manager.nvim
}
