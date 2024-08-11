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
        "prettier",
        "autopep8",
        "pyright",
        "rust",
      },
    },
  },
  -- Not sure what this does
  -- TODO: Does this even work? I don't have Python enabled, but it still
  -- highlights it. Maybe it does things other than highlighting as well??
  -- TODO: And another question... does this use Mason internally?
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "cpp",
        "javascript",
        "html",
        "css",
        "json",
      },
    },
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require "configs.harpoon"
    end,
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
  {
    -- TODO: Restoring the session doesn't open automatically the LSP plugin.
    --       Setup the event more correctly.
    "rmagatti/auto-session",
    lazy = false,
    dependencies = {
      "nvim-telescope/telescope.nvim", -- Only needed if you want to use sesssion lens
    },
    config = function()
      require "configs.auto-session"
    end,
  },
  -- TODO: Try in the future:
  -- https://github.com/folke/trouble.nvim
  -- https://github.com/mbbill/undotree
  -- https://github.com/tpope/vim-fugitive
}
