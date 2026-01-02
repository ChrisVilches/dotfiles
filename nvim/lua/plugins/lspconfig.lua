local function config_servers()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  vim.lsp.config("bashls", {
    filetypes = { "bash", "sh", "zsh" },
  })

  -- TODO: I have to make sure the capabilities (autocompletion) is doing something useful,
  -- and not just polluting the code without improving anything.
  vim.lsp.config("*", {
    capabilities = capabilities,
  })
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

    -- TODO: Remove this. It seems it's not necessary anymore.
    -- Test LSP responsiveness and attachment for a while. Then remove this.
    -- vim.api.nvim_create_autocmd("LspAttach", {
    --   callback = function(args)
    --     local bufnr = args.buf
    --     require "mappings.lsp"(bufnr)
    --   end,
    -- })

    config_servers()
    config_extra()
  end,
}
