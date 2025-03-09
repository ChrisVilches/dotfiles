return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
  opts = {
    provider = "openai",
    -- Remove the annoying hint popup when in visual mode. It originally shows these suggestions:
    -- <leader>aa ask (open the AI sidebar)
    -- <leader>ae edit (write a prompt where you explain how to edit the selected code/text)
    hints = { enabled = false },
    openai = {
      endpoint = "https://api.openai.com/v1",
      model = "gpt-4o", -- your desired model (or use gpt-4o, etc.)
      timeout = 30000, -- timeout in milliseconds
      temperature = 0, -- adjust if needed
      max_tokens = 4096,
      -- reasoning_effort = "high" -- only supported for reasoning models (o1, etc.)
    },
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "nvim-telescope/telescope.nvim",
    -- TODO: This plugin has the problem that the raw text becomes
    -- visible when the cursor is on the line, which makes it
    -- annoying because the entire text moves and it's hard to read.
    -- {
    --   "MeanderingProgrammer/render-markdown.nvim",
    --   opts = {
    --     file_types = { "markdown", "Avante" },
    --     anti_conceal = { enabled = true },
    --   },
    --   ft = { "markdown", "Avante" },
    -- },
    {
      -- TODO: This one doesn't show raw text when the cursor is on
      -- the lines, but it doesn't render immediately while the text
      -- is being outputted, and it hides the markdown characters
      -- so that if you press left/right it will need several key
      -- presses to change to the next visible character.
      "OXY2DEV/markview.nvim",
      branch = "main",
      opts = {
        preview = {
          filetypes = { "markdown", "Avante" },
          ignore_buftypes = {},
        },
        max_length = 99999,
      },
    },
  },
}
