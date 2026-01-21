return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
  event = { "BufReadPre", "BufNewFile" },
  -- TODO: It seems we need to upgrade soon, but currently
  -- it breaks a lot. Research how to do the upgrade correctly.
  -- This "branch = master" is the current workaround.
  -- https://github.com/nvim-treesitter/nvim-treesitter
  branch = "master",
  config = function()
    require("nvim-treesitter.configs").setup {
      auto_install = true,
      ignore_install = {},
      modules = {},
      sync_install = false,
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
        "markdown",
        "markdown_inline",
        "python",
        "ruby",
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
          },
        },
      },
    }
  end,
}
