local function current_dir_is_git_repo()
  local cwd = vim.fn.getcwd()
  local res = vim.fn.glob(cwd .. "/.git/")
  return #res > 0
end

return {
  "rmagatti/auto-session",
  lazy = false,
  -- dependencies = {
  --   "nvim-telescope/telescope.nvim", -- Only needed if you want to use session lens
  -- },
  config = function()
    require("auto-session").setup {
      auto_create = current_dir_is_git_repo,
    }
  end,
}
