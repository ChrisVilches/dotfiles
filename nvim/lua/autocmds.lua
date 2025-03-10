-- Remove trailing white space.
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  callback = function()
    local save_cursor = vim.fn.getpos "."
    pcall(function()
      vim.cmd [[%s/\s\+$//e]]
    end)
    vim.fn.setpos(".", save_cursor)
  end,
})

-- Close Neovim if nvim-tree is the only remaining window.
vim.api.nvim_create_autocmd("WinClosed", {
  callback = function(args)
    local is_nvimtree = vim.bo[args.buf].filetype == "NvimTree"
    local wins = vim.api.nvim_list_wins()

    if #wins == 2 and not is_nvimtree and require("utils").is_nvimtree_open() then
      vim.cmd ":SessionSave"
      vim.cmd ":qa"
    end
  end,
})
