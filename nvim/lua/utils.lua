-- This function should return only buffers listed in the tabs.
-- Not sure if that's how it works.
local current_buffers = function()
  return vim.tbl_filter(function(buf)
    return vim.bo[buf].buflisted
  end, vim.api.nvim_list_bufs())
end

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

  close_other_except_unsaved = function()
    local current_buf = vim.api.nvim_get_current_buf()

    for _, buf in ipairs(current_buffers()) do
      if buf ~= current_buf and not vim.bo[buf].modified then
        vim.api.nvim_buf_delete(buf, {})
      end
    end
  end,

  is_buffer_in_bufferline = function()
    local current_buf = vim.api.nvim_get_current_buf()

    for _, buf in ipairs(current_buffers()) do
      if buf == current_buf then
        return true
      end
    end

    return false
  end,
}
