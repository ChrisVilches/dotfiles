local themes = {
  { "catppuccin/nvim" },
  {
    "Shatur/neovim-ayu",
    config = function()
      require("ayu").setup { mirage = true }
    end,
  },
  { "ellisonleao/gruvbox.nvim" },
  { "folke/tokyonight.nvim" },
  { "rebelot/kanagawa.nvim" },
  { "projekt0n/github-nvim-theme" },
  { "EdenEast/nightfox.nvim" },
}

for _, plugin in ipairs(themes) do
  plugin.event = "VeryLazy"
end

return themes
