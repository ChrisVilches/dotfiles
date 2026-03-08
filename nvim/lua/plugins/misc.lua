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
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    -- TODO: Experiment enabling more widgets.
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      -- bigfile = { enabled = true },
      -- dashboard = { enabled = true },
      -- explorer = { enabled = true },
      indent = {
        priority = 1,
        enabled = true, -- enable indent guides
        char = "│",
        only_current = true, -- Only show indent guides in the current window
        only_scope = true, -- Only show indent guides of the scope
        hl = "SnacksIndent", ---@type string|string[] hl groups for indent guides
        animate = {
          enabled = false,
        },
      },
      input = { enabled = true },
      -- picker = { enabled = true },
      -- notifier = { enabled = true },
      -- quickfile = { enabled = true },
      -- scope = { enabled = true },
      -- scroll = { enabled = true },
      -- statuscolumn = { enabled = true },
      -- words = { enabled = true },
    },
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
  {
    -- Without this plugin, the Lua LSP will complain about things like "vim.lsp.get_clients" when coding in Neovim
    -- because it won't find the "vim" object.
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  -- TODO: Try in the future:
  -- Friendly snippets (currently I only use it for Lua because it's the default, but
  -- do it for other languages as well)
  -- https://github.com/folke/trouble.nvim
  -- https://github.com/mbbill/undotree
  -- https://github.com/gbprod/substitute.nvim
  -- https://github.com/nvim-telescope/telescope-smart-history.nvim
}
