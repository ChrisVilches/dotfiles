-- TODO: Telescope, sort files by most accessed????
-- check this out: https://www.youtube.com/watch?v=Qr-vX51gB8g
-- (video title: Sort files in telescope by showing the most accessed files first)
return {
  {
    "tpope/vim-surround",
    event = "VeryLazy",
  },
  {
    "mg979/vim-visual-multi",
    event = "VeryLazy",
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
  -- https://github.com/folke/trouble.nvim
  -- https://github.com/mbbill/undotree
  -- https://github.com/tpope/vim-fugitive
  -- https://github.com/folke/noice.nvim
  -- This one is for stopping using tabs
  -- https://github.com/j-morano/buffer_manager.nvim
}
