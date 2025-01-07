local function on_attach(bufnr)
  local api = require "nvim-tree.api"

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- default mappings
  api.config.mappings.default_on_attach(bufnr)

  -- NOTE: Make sure this mapping only works for the tree, and not for other buffers.
  -- I had a situation when my main <ESC> mapping stopped working (i.e. stopped clearing highlights)
  -- and it took me a while to realize it was because this was overriding that mapping!
  -- Also, that wouldn't have happened if I had added a clear description (which was becoming empty
  -- since I didn't add one before, so whichkey showed nothing useful when debugging).
  -- This binding also does "noh" to clear highlights, additionally to changing the window (just to make
  -- it more complete).
  -- TODO: Remove this comment in the future, since it's for general troubleshooting and not related
  -- to this file or plugin. This plugin is not the culprit, leave this plugin (and Britney) aloneee.
  -- (actually I was talking about the auto-session plugin)
  -- TODO: Note, I don't really use this mapping.
  vim.keymap.set("n", "<esc>", function()
    vim.cmd "noh"
    vim.cmd "wincmd l"
  end, { buffer = bufnr, desc = "change to right window" })

  -- custom mappings
  -- Make the info popup and navigation similar to the one in the code editor.
  vim.keymap.set("n", "K", api.node.show_info_popup, opts "Show information")
  vim.keymap.del("n", "<C-k>", { buffer = bufnr })
end

return {
  "nvim-tree/nvim-tree.lua",
  config = function()
    require("nvim-tree").setup {
      on_attach = on_attach,
      renderer = {
        root_folder_label = false,
      },
      update_focused_file = {
        enable = true,
      },
      filters = {
        enable = true,
        -- git_ignored = true,
        -- dotfiles = false,
        -- git_clean = false,
        -- no_buffer = false,
        -- no_bookmark = false,
        -- custom = {},
        -- custom = { ".git" },
      },
      -- git = {
      --   ignore = true,
      -- },
    }
  end,
}
