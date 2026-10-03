return {
  {
    dir = vim.fn.stdpath "config" .. "/custom-plugins",
    cmd = "Agi",
    config = function()
      vim.api.nvim_create_user_command("Agi", function(opts)
        require("agi").run(opts)
      end, {
        nargs = "*",
        range = true,
        desc = "Run the agi agent on the current file, at the cursor line or over the selected range",
      })
    end,
  },
}
