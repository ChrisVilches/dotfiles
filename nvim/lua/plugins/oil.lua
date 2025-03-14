local oil_dep = {
  -- TODO: A bit hard to use for me right now, but practice
  -- and use it mostly to do complex file movements/deletions/etc.
  -- (which I don't know how to do using nvim-tree lol)
  -- TODO: Remove these two TODO comments (verify and triage).
  "stevearc/oil.nvim",
  opts = {
    win_options = {
      signcolumn = "yes:2",
    },
    keymaps = {
      -- I prefer "<C-s> --> save" file, so disable this one.
      ["<C-s>"] = false,
      -- TODO: Verify that this copies all lines (another keymap I have) which is OK because that keymap should be used.
      ["<C-c>"] = false,
      -- TODO: Experimental. Is ESC good enough for this?
      ["<Esc>"] = { "actions.close", mode = "n" },
    },
  },
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    { "refractalize/oil-git-status.nvim", config = true },
  },
  -- -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
}

return {
  "refractalize/oil-git-status.nvim",
  cmd = "Oil",
  dependencies = oil_dep,
  -- TODO: But I want it to be lazy... The cmd="Oil" is good enough for my use case. But may not work properly.
  -- lazy = false, -- TODO: A weird "!" symbol appears if I use lazy=true (default) UPDATE: Ok it works now (i.e. no ! appears)..
  -- Ok sometimes I see the ! icons... maybe just set lazy=false? The documentation recommends that.. lol
  config = true,
}
