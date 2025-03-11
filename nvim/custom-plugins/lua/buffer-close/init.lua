local M = {}

local closed_files = require("stack").Stack:new()

local function delete_buf_and_arrange_tabs(bufnr)
  local buf = require "bufferline"
  buf.move(1)
  buf.cycle(-1)
  vim.api.nvim_buf_delete(bufnr, { force = true })
end

local function print_needs_to_save(file_path)
  local name = file_path
  if name == nil or name == "" then
    name = "unnamed"
  end
  vim.api.nvim_err_writeln("Needs to save before closing a buffer (" .. name .. ")")
end

local function push_history(file_path, view)
  closed_files:push { file_path, view }
end

local function close_aux(force)
  local bufnr = vim.fn.bufnr()
  local file_path = vim.api.nvim_buf_get_name(bufnr)
  local is_unnamed = file_path == nil or file_path == ""
  local is_modified = vim.bo[bufnr].modified
  local view = vim.fn.winsaveview()

  if is_modified and not force then
    print_needs_to_save(file_path)
    return
  end

  delete_buf_and_arrange_tabs(bufnr)

  if not is_unnamed then
    push_history(file_path, view)
  end
end

-- TODO: This function should return only buffers listed in the tabs.
-- Not sure if that's how it works.
local current_buffers = function()
  return vim.tbl_filter(function(buf)
    return vim.bo[buf].buflisted and vim.bo[buf].buftype ~= "terminal"
  end, vim.api.nvim_list_bufs())
end

function M.close_other_except_unsaved()
  local current_buf = vim.api.nvim_get_current_buf()

  for _, buf in ipairs(current_buffers()) do
    if buf ~= current_buf and not vim.bo[buf].modified then
      vim.api.nvim_buf_delete(buf, {})
    end
  end
end

function M.close()
  close_aux(false)
end

function M.close_force()
  close_aux(true)
end

function M.reopen_last()
  if closed_files:is_empty() then
    vim.api.nvim_err_writeln "No files to re-open"
    return
  end

  local file_path, view = unpack(closed_files:pop())

  if vim.uv.fs_stat(file_path) == nil then
    vim.api.nvim_err_writeln("Cannot re-open file: " .. file_path)
    return
  end

  vim.cmd("edit " .. vim.fn.fnameescape(file_path))
  vim.fn.winrestview(view)
end

return M
