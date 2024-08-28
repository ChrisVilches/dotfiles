return {
  -- TODO: It's a bit hard to see what is being required by which plugin, and
  --       to which category they belong (LSP, linter, formatter), so make sure to understand all that.
  --       Read about mason and how it works.
  "williamboman/mason.nvim",
  opts = {
    ensure_installed = {
      "codelldb",
      "clangd",
      "lua-language-server",
      "stylua",
      "html-lsp",
      "css-lsp",
      "gopls",
      "prettier",
      "autopep8",
      "pyright",
      "rust",
    },
  },
}
