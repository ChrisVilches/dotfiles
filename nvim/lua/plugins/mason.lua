-- NOTE: This error "loop or previous error loading module 'mason-lspconfig'" is produced by two files referencing
-- each other, and it seems it's a stackoverflow error (due to infinite recursion).
-- I fixed it by moving some parts to other files.

return {
  -- TODO: It's a bit hard to see what is being required by which plugin, and
  --       to which category they belong (LSP, linter, formatter), so make sure to understand all that.
  --       Read about mason and how it works.
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    -- TODO: I still don't understand exactly what mason does, so the refactoring of these files
    -- (mason.lua and lspconfig.lua will be later when I understand Mason well)

    require("mason").setup()
    require("mason-tool-installer").setup {
      ensure_installed = {
        "autopep8",
        "css-lsp",
        "clangd",
        "gopls",
        "lua-language-server",
        "pyright",
        "html-lsp",
        "php-cs-fixer",
        "prettier",
        "rust-analyzer",
        "stylua",
      },
    }
  end,
}
