return {
  "nvim-telescope/telescope-frecency.nvim",
  config = function()
    -- It seems some configurations must be here, and some others in the command that opens it.
    -- For example this command doesn't need "show_score" but needs "workspace" in order
    -- to show unindexed files:
    -- "<cmd> Telescope frecency workspace=CWD <CR>"
    -- May be a bug.
    require("telescope").setup {
      extensions = {
        frecency = {
          -- TODO: Adding this line removed the default prompt "A" but after the first time, it stopped appearing,
          -- so I don't need it anymore, it seems. Add it again if the default prompt problem arises again.
          -- https://github.com/nvim-telescope/telescope-frecency.nvim/issues/270
          -- db_safe_mode = false,
          show_scores = true,
          show_unindexed = true,
        },
      },
    }
  end,
}
