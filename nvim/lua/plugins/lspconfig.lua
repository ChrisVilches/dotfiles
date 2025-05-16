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
    -- TODO: It seems now I can't go to other files with the "go to definition" trick.
    -- (this plugin mason-lspconfig was updated lately, maybe that broke it.)
    -- What happened here is that the previous setup had some more logic (see the code
    -- in the commit history) and one of those things was to load the lsp mappings.
    -- Now those mappings aren't even loaded!! so I lost a lot of LSP functionality.
    --
    -- Here are some other problems:
    -- Sometimes I have to close a file and then open it again to make ctrl+k (hover) available
    -- Can't gd into other files (go to definition)
    require("mason-lspconfig").setup()

    -- Avoid underlining the whole text when there's a diagnostic.
    vim.diagnostic.config {
      underline = false,
      virtual_text = true,
    }
  end,
}
