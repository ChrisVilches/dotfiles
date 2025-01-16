return {
  "nvim-lualine/lualine.nvim",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- These are for the lsp-progress block.
    vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
    vim.api.nvim_create_autocmd("User", {
      group = "lualine_augroup",
      pattern = "LspProgressStatusUpdated",
      callback = require("lualine").refresh,
    })

    require("lualine").setup {
      sections = {
        lualine_b = {
          "branch",
          "diff",
          {
            function()
              return vim.g.colors_name
            end,
          },
        },
        lualine_c = {
          function()
            return require("lsp-progress").progress()
          end,
        },
      },
    }
  end,
}
