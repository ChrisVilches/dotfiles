-- TODO: Telescope, sort files by most accessed????
-- check this out: https://www.youtube.com/watch?v=Qr-vX51gB8g
-- (video title: Sort files in telescope by showing the most accessed files first)
return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufEnter",
  },
  {
    "tpope/vim-surround",
    event = "BufEnter",
  },
  {
    "mg979/vim-visual-multi",
    event = "BufEnter",
  },
  {
    -- TODO: Nice, but keep in mind tab order and the order in this plugin may be different, which makes it
    --       a bit confusing sometimes. If I get used to it, remove this TODO comment.
    "j-morano/buffer_manager.nvim",
    event = "BufEnter",
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

  -- TODO: Try in the future:
  -- Friendly snippets (currently I only use it for Lua because it's the default, but
  -- do it for other languages as well)
  -- https://github.com/folke/trouble.nvim
  -- https://github.com/mbbill/undotree
  -- https://github.com/folke/noice.nvim
}
