return {
  "nvim-lualine/lualine.nvim",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
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
      },
    }
  end,
}
