return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
  opts = {
    -- Remove the annoying hint popup when in visual mode. It originally shows these suggestions:
    -- <leader>aa ask (open the AI sidebar)
    -- <leader>ae edit (write a prompt where you explain how to edit the selected code/text)
    -- <leader>an new ask (useful because otherwise it keeps the previous conversations and consume many tokens!)
    -- <leader>aS stop current AI request (will print: "Request cancelled by user")
    selection = {
      enabled = false,
    },
    provider = "openai",
    providers = {
      openai = {
        endpoint = "https://api.openai.com/v1",
        model = "gpt-4o",
        timeout = 30000, -- timeout in milliseconds
        max_tokens = 4096,
        -- reasoning_effort = "high" -- only supported for reasoning models (o1, etc.)
        extra_request_body = {
          temperature = 0,
        },
      },
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
    "nvim-tree/nvim-web-devicons",
    "nvim-telescope/telescope.nvim",
    {
      "OXY2DEV/markview.nvim",
      --   Alternative:
      --   "MeanderingProgrammer/render-markdown.nvim",
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
