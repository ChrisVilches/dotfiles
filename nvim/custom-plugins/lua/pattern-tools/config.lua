local M = {}

M.opts = {
  macro_reg = "a",
}

function M.setup(custom_opts)
  local merged = vim.tbl_extend("force", M.opts, custom_opts)

  vim.validate {
    macro_reg = { merged.macro_reg, "string", false },
  }

  M.opts = merged
end

return M
