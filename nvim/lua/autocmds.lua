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

-- Reload my custom theme automatically.
-- Should only work in this repo (configs repo).
-- From other repos, you can just re-execute the colorscheme command (and it will work
-- without having to exit neovim).
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  pattern = "nvim/lua/retroblue/*",
  callback = function()
    local curr_theme = vim.g.colors_name

    if not curr_theme:match "^retroblue" then
      return
    end

    -- Remove from require cache.
    for key, _ in pairs(package.loaded) do
      if key:match "retroblue" then
        package.loaded[key] = false
      end
    end

    -- Not using vim.schedule() messes up the tabs (I think)
    vim.schedule(function()
      vim.cmd("colorscheme " .. curr_theme)
    end)
  end,
})
