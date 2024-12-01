local themes = {
  {
    "catppuccin/nvim",
    config = function(_, opts)
      require("catppuccin").setup(opts)
    end,
  },
  -- TODO: Kinda works, but the default "blue" one is better. It has more colors.
  { "luckydev/150colors" },
  {
    "Shatur/neovim-ayu",
    config = function()
      require("ayu").setup { overrides = { Normal = { bg = "None" } } }
    end,
  },
  { "ellisonleao/gruvbox.nvim" },
  { "folke/tokyonight.nvim" },
  { "rebelot/kanagawa.nvim" },
  {
    "projekt0n/github-nvim-theme",
    config = function()
      require("github-theme").setup { options = { transparent = false } }
    end,
  },
  {
    "navarasu/onedark.nvim",
    config = function()
      require("onedark").setup { style = "darker" }
    end,
  },
}

for _, plugin in ipairs(themes) do
  plugin.event = "VeryLazy"
end

return themes
