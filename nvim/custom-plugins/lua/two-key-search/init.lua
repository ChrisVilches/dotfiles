local msg = "Press two keys for search: "
local esc = 27

return function()
  local keys = ""
  vim.api.nvim_echo({ { msg, "Normal" } }, false, {})

  for _ = 1, 2 do
    local ok, char = pcall(vim.fn.getchar)
    if not ok or char == esc then
      return
    end

    if type(char) == "number" then
      char = vim.fn.nr2char(char)
    end

    keys = keys .. char

    vim.api.nvim_echo({ { msg .. keys, "Normal" } }, false, {})
  end

  local found = vim.fn.search(keys)

  -- TODO: Should I keep this here? if it's here, it won't setup the registers, so it keeps
  -- the previous search pattern. Which is kinda good, but also non-standard because the normal
  -- search / works that way (it still sets the pattern).
  if found == 0 then
    vim.notify("Pattern not found: " .. keys, vim.log.levels.WARN)
    return
  end

  vim.fn.setreg("/", keys)
  vim.cmd "set hlsearch"
end
