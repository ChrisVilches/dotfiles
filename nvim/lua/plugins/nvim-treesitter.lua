return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("nvim-treesitter.configs").setup {
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<leader>i",
          node_incremental = "<leader>i",
          scope_incremental = false,
          node_decremental = "<leader>d",
        },
      },
      ensure_installed = {
        "cpp",
        "css",
        "go",
        "html",
        "javascript",
        "json",
        "lua",
        "rust",
        "typescript",
        "vim",
        "vimdoc",
      },
      textobjects = {
        select = {
          include_surrounding_whitespace = true,
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["=l"] = "@assignment.lhs",
            ["=r"] = "@assignment.rhs",
          },
        },
      },
    }
  end,
}
