local function on_attach(bufnr)
  local api = require "nvim-tree.api"

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- default mappings
  api.config.mappings.default_on_attach(bufnr)

  vim.keymap.set("n", "<esc>", function()
    vim.cmd "wincmd l"
  end)

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
