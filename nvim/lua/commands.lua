vim.api.nvim_create_user_command("CopyRelPath", function()
  vim.api.nvim_call_function("setreg", { "+", vim.fn.fnamemodify(vim.fn.expand "%", ":.") })
end, { desc = "Copy the relative path of the current file to the clipboard" })
