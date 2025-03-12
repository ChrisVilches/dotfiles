return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  config = function()
    require("conform").setup {
      formatters_by_ft = {
        ruby = {},
        json = { "jq" },
        lua = { "stylua" },
        cpp = { "clang-format" },
        python = { "autopep8" },
        quarto = { "injected" },
        -- php = { "php-cs-fixer" },
        -- css = { "prettier" },
        -- html = { "prettier" },
      },

      format_on_save = {
        -- These options will be passed to conform.format()
        timeout_ms = 500,
        async = false,
        lsp_fallback = true,
      },
    }

    -- TODO: Grabbed this code from the Quarto kickstarter (verify it's correct and make
    -- sure it does something useful).
    require("conform").formatters.injected = {
      -- Set the options field
      options = {
        -- Set to true to ignore errors
        ignore_errors = false,
        -- Map of treesitter language to file extension
        -- A temporary file name with this extension will be generated during formatting
        -- because some formatters care about the filename.
        lang_to_ext = {
          bash = "sh",
          c_sharp = "cs",
          elixir = "exs",
          javascript = "js",
          julia = "jl",
          latex = "tex",
          markdown = "md",
          python = "py",
          ruby = "rb",
          rust = "rs",
          teal = "tl",
          r = "r",
          typescript = "ts",
        },
        -- Map of treesitter language to formatters to use
        -- (defaults to the value from formatters_by_ft)
        lang_to_formatters = {},
      },
    }
  end,
}
