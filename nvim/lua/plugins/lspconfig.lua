local function config_servers()
  vim.lsp.config("bashls", {
    filetypes = { "bash", "sh", "zsh" },
  })

  -- To verify if capabilities are working, disable the entire LSP for a language
  -- and compare behaviors. Autocompletion is difficult to disable via
  -- configuration, so the menu might show the same candidates. However,
  -- disabling the LSP will clearly remove those provided by it.
  -- Configuring LSP servers can be challenging as mason-lspconfig
  -- handles some configurations automatically.
end

local function config_extra()
  -- Avoid underlining the whole text when there's a diagnostic.
  vim.diagnostic.config {
    underline = false,
    virtual_text = true,
  }
end

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    require("mason-lspconfig").setup()

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        require "mappings.lsp"(args.buf)
      end,
    })

    config_servers()
    config_extra()
  end,
}
