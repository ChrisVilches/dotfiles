return {
  current_dir_is_git_repo = function()
    local cwd = vim.fn.getcwd()
    local res = vim.fn.glob(cwd .. "/.git/")
    return #res > 0
  end,

  restore_nvim_tree = function()
    local nvim_tree_api = require "nvim-tree.api"
    nvim_tree_api.tree.open()
    nvim_tree_api.tree.change_root(vim.fn.getcwd())
    nvim_tree_api.tree.reload()
  end,

  toggle_tree_code = function()
    local curr_winid = vim.api.nvim_get_current_win()
    local tree = require("nvim-tree.api").tree

    if curr_winid == tree.winid() then
      -- NOTE: Only works if the code is to the right.
      vim.api.nvim_command "wincmd l"
    else
      tree.focus()
    end
  end,
}
