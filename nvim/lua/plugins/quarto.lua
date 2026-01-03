local function add_snippets()
  -- These snippets are added here instead of in the ftplugin to prevent them
  -- from being added multiple times, which would occur each time a qmd file is opened.
  local luasnip = require "luasnip"
  luasnip.add_snippets("quarto", {
    luasnip.parser.parse_snippet(
      "metadata",
      [[
---
title: "$1"
format:
  html:
    code-fold: true
jupyter: python3
---]]
    ),
    -- NOTE: Occasionally, this may result in four or more backticks being
    -- printed, likely due to autopairs or another autocompletion plugin.
    -- Ensure to verify correctness after using this.
    luasnip.parser.parse_snippet("```{python}", "```{python}\n$1\n```\n"),
  })
end

return {
  "quarto-dev/quarto-nvim",
  ft = { "quarto" },
  dev = false,
  opts = {
    codeRunner = {
      enabled = true,
      default_method = "molten",
    },
  },
  config = function(_, opts)
    require("quarto").setup(opts)
    add_snippets()
  end,
  dependencies = {
    -- for language features in code cells
    -- configured in lua/plugins/lsp.lua and
    -- added as a nvim-cmp source in lua/plugins/completion.lua
    {
      -- for lsp features in code cells / embedded code
      "jmbuhr/otter.nvim",
      dev = false,
      dependencies = {
        {
          "neovim/nvim-lspconfig",
          "nvim-treesitter/nvim-treesitter",
        },
      },
    },
    -- {
    --   Enable and try someday (preview equations)
    --   "jbyuki/nabla.nvim",
    -- },
    {
      "benlubas/molten-nvim",
      -- NOTE: This needs a lot of external dependencies so make sure you run 'checkhealth molten'
      build = ":UpdateRemotePlugins",
      init = function()
        vim.g.molten_output_win_max_height = 20
        -- Automatically open the floating output window when your cursor moves into a cell
        vim.g.molten_auto_open_output = false

        -- When true, cells that produce an image output will open the image output automatically with python's Image.show()
        vim.g.molten_auto_image_popup = true

        -- Pad the main buffer with virtual lines so the floating window doesn't cover anything while it's open
        vim.g.molten_output_virt_lines = true

        -- When true, show output as virtual text below the cell, virtual text stays after leaving the cell. When true, output window doesn't open automatically on run. Effected by virt_lines_off_by_1
        vim.g.molten_virt_text_output = true

        -- The output window and virtual text will be shown just below the last line of code in the cell.
        vim.g.molten_cover_empty_lines = false

        -- vim.g.molten_auto_open_html_in_browser = true

        -- When the window can't display the entire contents of the output buffer, shows the number of extra lines in the window footer (requires nvim 10.0+ and a window border)
        -- vim.g.molten_output_show_more = true
      end,
    },
  },
}
