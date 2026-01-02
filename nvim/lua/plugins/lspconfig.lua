local function on_init(client)
  -- TODO: Should i do something like this in my LSP? (this was in the Quarto kickstarter).
  -- local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
  -- capabilities.textDocument.completion.completionItem.snippetSupport = true

  if client.server_capabilities then
    -- Disable semantic tokens to prevent errors from incomplete LSP support.
    client.server_capabilities.semanticTokensProvider = false
  end
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
        local bufnr = args.buf
        require "mappings.lsp"(bufnr)
      end,
    })

    vim.lsp.config("bashls", {
      filetypes = { "bash", "sh", "zsh" },
    })

    -- Avoid underlining the whole text when there's a diagnostic.
    vim.diagnostic.config {
      underline = false,
      virtual_text = true,
    }
  end,
}
