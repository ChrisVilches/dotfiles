local utils = require "utils"

return {
  -- TODO: Restoring the session doesn't open automatically the LSP plugin.
  --       Setup the event more correctly.
  --       This one is probably fixed since I revamped the LSP.
  "rmagatti/auto-session",
  lazy = false,
  -- dependencies = {
  --   "nvim-telescope/telescope.nvim", -- Only needed if you want to use session lens
  -- },
  config = function()
    local function handle_restore()
      if utils.current_dir_is_git_repo() then
        utils.restore_nvim_tree()
      end
    end

    require("auto-session").setup {
      auto_create = utils.current_dir_is_git_repo,
      post_restore_cmds = { handle_restore },
    }
  end,
}
