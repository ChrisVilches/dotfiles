return {
  {
    dir = vim.fn.stdpath "config" .. "/custom-plugins",
    config = function()
      require("pattern-tools.config").setup { macro_reg = "a" }
    end,
  },
  { dir = vim.fn.stdpath "config" .. "/custom-themes/retroblue", event = "VeryLazy" },
}
