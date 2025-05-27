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
    -- TODO: Hover appears as a new window instead of as a floating popup. (it
    -- gets fixed if you close and re-open the file)
    local mason = require "mason-lspconfig"
    local lspconfig = require "lspconfig"

    mason.setup()

    for _, server_name in ipairs(mason.get_installed_servers()) do
      lspconfig[server_name].setup {
        on_init = on_init,
        on_attach = function(_, bufnr)
          require "mappings.lsp"(bufnr)
        end,
      }
    end

    -- Avoid underlining the whole text when there's a diagnostic.
    vim.diagnostic.config {
      underline = false,
      virtual_text = true,
    }
  end,
}
