-- NOTE: This error "loop or previous error loading module 'mason-lspconfig'" is produced by two files referencing
-- each other, and it seems it's a stackoverflow error (due to infinite recursion).
-- I fixed it by moving some parts to other files.

return {
  "williamboman/mason.nvim",
  dependencies = {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    require("mason").setup()
    require("mason-tool-installer").setup {
      ensure_installed = {
        "autopep8",
        "clangd",
        "css-lsp",
        -- "eslint",
        "gopls",
        "html-lsp",
        "lua-language-server",
        "php-cs-fixer",
        "prettier",
        "pyright",
        "rust-analyzer",
        "stylua",
        "luacheck",
      },
    }
  end,
}
