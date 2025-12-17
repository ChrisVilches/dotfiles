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
    local action_state = require "telescope.actions.state"
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
          "--glob",
          "!.git/*",
        },
        sorting_strategy = "ascending",
        layout_config = {
          prompt_position = "top",
        },
        path_display = { "smart" },
        mappings = {
          n = {
            p = function(prompt_bufnr)
              -- Remove the trailing newline character when pasting an entire
              -- line into the Telescope prompt. This ensures the
              -- paste operation works correctly.
              local current_picker = action_state.get_current_picker(prompt_bufnr)
              local text = vim.fn.getreg("+"):gsub("\n$", "")
              current_picker:set_prompt(text, false)
            end,
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
