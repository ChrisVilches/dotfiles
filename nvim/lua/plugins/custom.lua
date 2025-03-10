return {
  {
    dir = vim.fn.stdpath "config" .. "/lua/custom-plugins/toggle-fullscreen",
    -- TODO: This should be done using "config = true", in a more automatic way
    -- config = true,
    config = function()
      require("custom-plugins.toggle-fullscreen").config()
    end,
    event = "VeryLazy",
  },
  {
    dir = vim.fn.stdpath "config" .. "/lua/custom-plugins/preview-file",
    -- TODO: This should be done using "config = true", in a more automatic way
    -- config = true,
    event = "VeryLazy",
  },
  {
    dir = vim.fn.stdpath "config" .. "/lua/custom-plugins/retroblue",
    event = "VeryLazy",
  },
}
