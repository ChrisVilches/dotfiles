return {
  current_dir_is_git_repo = function()
    local cwd = vim.fn.getcwd()
    local res = vim.fn.glob(cwd .. "/.git/")
    return #res > 0
  end,

  -- TODO: Beta, but so far it works.
  -- Maybe there are some corner cases where the tree accesses some other window like a popup, and then
  -- executing this would toggle the popup, ... I don't know.
  toggle_tree_code = function()
    local curr_id = vim.api.nvim_get_current_win()
    local tree = require("nvim-tree.api").tree

    if curr_id == tree.winid() then
      local prev_winid = vim.fn.win_getid(vim.fn.winnr "#")
      vim.api.nvim_set_current_win(prev_winid)
    else
      tree.focus()
    end
  end,
}
