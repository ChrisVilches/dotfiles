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
    "OXY2DEV/markview.nvim",
    --   Alternative:
    --   "MeanderingProgrammer/render-markdown.nvim",
    branch = "main",

    -- Markview listens for the buffers it previews itself, and the event it
    -- would be loaded on here is the one it has to have been listening for
    -- already, so loading it lazily costs it the first buffer of a session
    -- rather than saving anything. Said outright, because the global default
    -- is the other way around.
    lazy = false,

    opts = {
      preview = {
        -- filetypes = { "markdown", "Avante" },

        -- Markview leaves "nofile" buffers alone by default, taking them for
        -- scratch space rather than documents. The output windows of the
        -- custom plugins here are nofile and are markdown meant to be read.
        ignore_buftypes = {},

        -- Past this many lines Markview draws only what a window is showing.
        max_buf_lines = 99999,
      },
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
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
  },
  -- TODO: Try in the future:
  -- Friendly snippets (currently I only use it for Lua because it's the default, but
  -- do it for other languages as well)
  -- https://github.com/folke/trouble.nvim
  -- https://github.com/mbbill/undotree
  -- https://github.com/gbprod/substitute.nvim
}
