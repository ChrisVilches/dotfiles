local function map(keymap, telescope_cmd, desc)
  vim.keymap.set(
    "n",
    "<leader>" .. keymap,
    "<cmd>Telescope " .. telescope_cmd .. "<CR>",
    { desc = "Telescope: " .. desc }
  )
end

-- More pickers: https://github.com/nvim-telescope/telescope.nvim?tab=readme-ov-file#pickers
map("fw", "live_grep theme=ivy", "live grep")
map("fg", "grep_string", "grep string")
map("fh", "help_tags", "help page")
map("ma", "marks", "find marks")
map("fo", "oldfiles", "find oldfiles")
map("fz", "current_buffer_fuzzy_find", "find in current buffer")
map("flb", "lsp_document_symbols", "Lists LSP document symbols in the current buffer")
map("flw", "lsp_workspace_symbols", "Lists LSP document symbols in the current workspace")
map("cm", "git_commits", "git commits")
map("gt", "git_status", "git status")
map("fa", "find_files follow=true no_ignore=true hidden=true", "find all files")
map("ff", 'frecency workspace=CWD path_display={"truncate"} theme=ivy', "find files (frecency)")
map("<tab>", "buffers", "show current buffers")

vim.keymap.set("n", "<leader>re", function()
  require("telescope.builtin").registers { initial_mode = "normal" }
end)

vim.keymap.set("n", "<leader>th", function()
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"

  require("telescope.builtin").colorscheme {
    enable_preview = true,
    attach_mappings = function()
      actions.select_default:replace(function(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.cmd("colorscheme " .. selection.value)
      end)
      return true
    end,
  }
end, { desc = "theme picker" })
