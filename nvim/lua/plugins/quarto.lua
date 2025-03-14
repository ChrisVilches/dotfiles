-- TODO: Error: close a quarto file, then open it again, a Diagnostics-related (and Otter) error appears.
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
      opts = {
        verbose = {
          no_code_found = false,
        },
      },
    },
    -- {
    --   -- TODO: Enable and try someday.
    --   -- preview equations
    --   "jbyuki/nabla.nvim",
    --   enabled = false,
    --   keys = {
    --     { "<leader>qm", ':lua require"nabla".toggle_virt()<cr>', desc = "toggle math equations" },
    --   },
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
        -- TODO: Maybe this would be good for when a Pandas series has a lot of data, etc.
        -- vim.g.molten_output_show_more = true
      end,
    },
  },
}
