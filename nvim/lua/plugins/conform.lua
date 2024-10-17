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
  end,
}
