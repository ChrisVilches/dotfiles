local oil_dep = {
  "stevearc/oil.nvim",
  opts = {
    win_options = {
      signcolumn = "yes:2",
    },
    float = {
      -- Configure the width so it doesn't overlap with the nvim-tree,
      -- allowing you to view both oil and nvim-tree simultaneously.
      max_width = 0.6,
    },
    keymaps = {
      ["<C-s>"] = false, -- I prefer "<C-s> = save file", so disable this one.
      ["<C-c>"] = false,
      ["<Esc>"] = { "actions.close", mode = "n" },
    },
  },
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
}

return {
  "refractalize/oil-git-status.nvim",
  dependencies = oil_dep,
  config = true,
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
}
