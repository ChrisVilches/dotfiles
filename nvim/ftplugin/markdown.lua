local map = vim.keymap.set

local function opts(desc)
  return { desc = "markdown: " .. desc, buffer = 0, noremap = true, silent = true, nowait = true }
end

local function toggle_todo()
  local mark = vim.api.nvim_get_current_line():match "^%s*-%s+%[%s*(x?)%s*%]"

  local mark_map = {
    ["x"] = " ",
    [""] = "x",
  }

  if mark_map[mark] then
    vim.cmd("normal! ^ci[" .. mark_map[mark])
    vim.cmd "normal! f]w"
  end
end

map("n", "<leader>ok", toggle_todo, opts "Toggle to-do item completion")
