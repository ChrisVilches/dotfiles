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
  -- TODO: commit this one (nightfox), but remove a few.
  -- TODO: commit the ayu changes. It didn't work well with those color overrides (bufferline looked bad)
  { "EdenEast/nightfox.nvim" },
}

for _, plugin in ipairs(themes) do
  plugin.event = "VeryLazy"
end

return themes
