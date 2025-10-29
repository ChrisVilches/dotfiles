local function current_dir_is_git_repo()
  local cwd = vim.fn.getcwd()
  local res = vim.fn.glob(cwd .. "/.git/")
  return #res > 0
end

local function restore_nvim_tree()
  local nvim_tree_api = require "nvim-tree.api"

  -- Restore the nvim-tree while maintaining the cursor position in the code window.
  local win_id = vim.api.nvim_get_current_win()
  local cursor_pos = vim.api.nvim_win_get_cursor(win_id)
  nvim_tree_api.tree.open()
  nvim_tree_api.tree.change_root(vim.fn.getcwd())
  nvim_tree_api.tree.reload()
  vim.api.nvim_set_current_win(win_id)
  pcall(vim.api.nvim_win_set_cursor, win_id, cursor_pos)
end

return {
  "rmagatti/auto-session",
  lazy = false,
  -- dependencies = {
  --   "nvim-telescope/telescope.nvim", -- Only needed if you want to use session lens
  -- },
  config = function()
    local function handle_restore()
      -- Without the `vim.schedule` it sometimes doesn't load the LSP, highlights,
      -- ftplugin, etc.
      vim.schedule(function()
        if current_dir_is_git_repo() then
          restore_nvim_tree()
        end
      end)
    end

    require("auto-session").setup {
      auto_create = current_dir_is_git_repo,
      post_restore_cmds = { handle_restore },
    }
  end,
}
