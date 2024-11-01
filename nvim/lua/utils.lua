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

  is_buffer_in_bufferline = function()
    local current_buf = vim.api.nvim_get_current_buf()

    local listed_buffers = vim.tbl_filter(function(buf)
      return vim.bo[buf].buflisted
    end, vim.api.nvim_list_bufs())

    for _, buf in ipairs(listed_buffers) do
      if buf == current_buf then
        return true
      end
    end

    return false
  end,
}
