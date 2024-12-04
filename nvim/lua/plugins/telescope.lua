return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local telescope = require "telescope"
    local action_set = require "telescope.actions.set"
    telescope.setup {
      defaults = {
        sorting_strategy = "ascending",
        layout_config = {
          prompt_position = "top",
        },
        path_display = { "smart" },
        mappings = {
          n = {
            ["<C-j>"] = function(prompt_bufnr)
              action_set.shift_selection(prompt_bufnr, 6)
            end,
            ["<C-k>"] = function(prompt_bufnr)
              action_set.shift_selection(prompt_bufnr, -6)
            end,
          },
        },
      },
    }

    telescope.load_extension "fzf"
  end,
}
