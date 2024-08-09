local utils = require "utils"

local function handle_restore()
  if utils.current_dir_is_git_repo() then
    utils.restore_nvim_tree()
  end
end

require("auto-session").setup {
  post_restore_cmds = { handle_restore },
  auto_session_create_enabled = utils.current_dir_is_git_repo,
}
