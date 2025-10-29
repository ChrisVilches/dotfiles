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
    local actions = require "telescope.actions"
    local action_set = require "telescope.actions.set"
    telescope.setup {
      defaults = {
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
        },
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
            -- Originally mapped to CTRL+Q, but that's my TMUX prefix.
            ["<C-a>"] = actions.send_to_qflist + actions.open_qflist,
          },
          i = {
            ["<C-a>"] = actions.send_to_qflist + actions.open_qflist,
          },
        },
      },
    }

    telescope.load_extension "fzf"
  end,
}
