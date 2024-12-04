return {
  "lukas-reineke/indent-blankline.nvim",
  event = { "BufReadPre", "BufNewFile" },
  main = "ibl",
  config = function()
    -- local highlight = { "current" }
    --
    -- local hooks = require "ibl.hooks"
    --
    -- hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    --   vim.api.nvim_set_hl(0, "current", { fg = "#888888" })
    -- end)
    --
    require("ibl").setup {
      indent = {
        char = "▏",
      },
      scope = {
        -- Remove the annoying underline.
        -- A highlight would be better, but maybe it's not possible
        -- to display that with this plugin.
        show_start = false,
        show_end = false,
        -- enabled = false,
        -- highlight = highlight,
      },
    }
  end,
}
