local function config()
  local mc = require "multicursor-nvim"
  mc.setup()

  local set = vim.keymap.set

  -- Add cursor above/below the main cursor.
  set({ "n", "x" }, "<up>", function()
    mc.lineAddCursor(-1)
  end)
  set({ "n", "x" }, "<down>", function()
    mc.lineAddCursor(1)
  end)

  -- Add a new cursor by matching word/selection
  set({ "n", "x" }, "<leader>n", function()
    mc.matchAddCursor(1)
  end)
  set({ "n", "x" }, "<leader>N", function()
    mc.matchAddCursor(-1)
  end)

  -- Mappings defined in a keymap layer only apply when there are
  -- multiple cursors. This lets you have overlapping mappings.
  mc.addKeymapLayer(function(layerSet)
    -- Select a different cursor as the main one.
    layerSet({ "n", "x" }, "<leader><up>", mc.prevCursor)
    layerSet({ "n", "x" }, "<leader><down>", mc.nextCursor)

    -- Enable and clear cursors using escape.
    layerSet("n", "<esc>", mc.clearCursors)
  end)

  -- Customize how cursors look.
  local hl = vim.api.nvim_set_hl
  hl(0, "MultiCursorCursor", { link = "Cursor" })
  hl(0, "MultiCursorVisual", { link = "Visual" })
  hl(0, "MultiCursorSign", { link = "SignColumn" })
  hl(0, "MultiCursorMatchPreview", { link = "Search" })
  hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
  hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
  hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
end

return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  event = "BufEnter",
  config = function()
    -- It needs to be inside a schedule in order to pick up the leader mapping,
    -- also if it's outside schedule, the cursors aren't highlighted (maybe it needs
    -- to load some styles). At any rate it's better to load it like this, or using
    -- event = "VeryLazy" for it to work properly.
    vim.schedule(config)
  end,
}
