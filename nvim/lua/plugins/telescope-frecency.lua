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
          show_scores = true,
          show_unindexed = true,
        },
      },
    }
  end,
}
