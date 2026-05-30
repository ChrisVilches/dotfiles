return {
  "romus204/tree-sitter-manager.nvim",
  lazy = false,
  config = function()
    require("tree-sitter-manager").setup({
      ensure_installed = { "cpp", "javascript" },
      highlight = true,
    })
  end
}
