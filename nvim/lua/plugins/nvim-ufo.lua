local function config()
  -- NOTE: The session plugin may disable or change some of these options.

  vim.o.foldcolumn = "0" -- '0' is not bad
  vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
  vim.o.foldlevelstart = 99
  vim.o.foldenable = true

  require("ufo").setup {
    provider_selector = function(_, _, _)
      return { "treesitter", "indent" }
    end,
  }
end

return {
  "kevinhwang91/nvim-ufo",
  event = "BufEnter",
  dependencies = { "kevinhwang91/promise-async" },
  config = config,
}

-- Main fold usage:
-- za to fold a block
-- za to unfold a block
-- zM to fold all
-- zR to unfold all
-- There are many other ways to fold, but these are the simplest ways.
