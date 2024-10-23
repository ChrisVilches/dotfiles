return {
  "akinsho/bufferline.nvim",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  opts = {
    options = {
      mode = "tabs",
      separator_style = "slant",
    },
  },
  config = function()
    -- TODO: Tabs still look like shite.
    -- Try to use colors from the theme, so they get configured automatically instead of me hardcoding some colors.
    -- and perhaps try to modify the indent blankline plugin the same way (with colors from the theme).
    require("bufferline").setup {}
  end,
}
