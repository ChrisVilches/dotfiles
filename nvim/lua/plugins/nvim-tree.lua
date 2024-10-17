return {
  "nvim-tree/nvim-tree.lua",
  config = function()
    require("nvim-tree").setup {
      renderer = {
        root_folder_label = false
      },
      update_focused_file = {
        enable = true,
      },
      -- git = {
      --   ignore = true,
      -- },
    }
  end,
}
