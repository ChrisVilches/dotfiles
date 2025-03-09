-- NOTE: This error "loop or previous error loading module 'mason-lspconfig'" is produced by two files referencing
-- each other, and it seems it's a stackoverflow error (due to infinite recursion).
-- I fixed it by moving some parts to other files.

-- TODO: I have an idea... Maybe add the ensure_installed for each category (LSP, linters, formatters, etc)
-- in the plugin file they belong to. So that means the Mason plugin would just contain the "config = true"
-- and nothing else. The things to download would be located in the LSP plugin file, linter plugin file,
-- and formatter plugin file.
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
      },
    }
  end,
}
