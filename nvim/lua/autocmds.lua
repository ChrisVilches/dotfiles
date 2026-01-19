-- Remove trailing white space and leading empty lines.
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  callback = function()
    local save_cursor = vim.fn.getpos "."
    vim.cmd [[%s/\s\+$//e]]
    vim.cmd [[%s/\%^\n\+//e]]
    vim.fn.setpos(".", save_cursor)
  end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = require("sessions").save_session,
})
