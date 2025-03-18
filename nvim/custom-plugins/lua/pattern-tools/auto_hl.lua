-- TODO: Needs a lot of testing and debugging but it seems to be working alright.
local util = require "pattern-tools.util"

local group = nil

local function clear_autocmds()
  if group ~= nil then
    vim.api.nvim_del_augroup_by_id(group)
    group = nil
  end
end

local function listen_enter_visual_and_cursor(cb)
  -- Detects changes between visual and line selection modes to update highlights accordingly.
  vim.api.nvim_create_autocmd("ModeChanged", {
    group = group,
    pattern = "*:[vV]",
    callback = cb,
  })

  vim.api.nvim_create_autocmd("CursorMoved", { group = group, callback = cb })
end

local function listen_exit_visual(cb)
  vim.api.nvim_create_autocmd("ModeChanged", {
    group = group,
    pattern = "*:*",
    callback = function()
      if not util.mode_is_visual() then
        cb()
      end
    end,
  })
end

local update_hl = function()
  vim.fn.setreg("/", util.get_escaped_selection())
  vim.cmd [[set hlsearch]]
end

local function auto_highlight()
  group = vim.api.nvim_create_augroup("VisualCursorMoved", { clear = true })

  update_hl()
  listen_enter_visual_and_cursor(update_hl)
  listen_exit_visual(clear_autocmds)
end

return function()
  if group ~= nil then
    clear_autocmds()
    return
  end

  auto_highlight()
end
