-- NOTE: This error "loop or previous error loading module 'mason-lspconfig'" is produced by two files referencing
-- each other, and it seems it's a stackoverflow error (due to infinite recursion).
-- I fixed it by moving some parts to other files.

return {
  "williamboman/mason.nvim",
  config = true,
}
