local function current_dir_is_git_repo()
  local cwd = vim.fn.getcwd()
  local res = vim.fn.glob(cwd .. "/.git/")
  return #res > 0
end

return {
  "rmagatti/auto-session",
  lazy = false,
  -- dependencies = {
  --   "nvim-telescope/telescope.nvim", -- Only needed if you want to use session lens
  -- },
  config = function()
    require("auto-session").setup {
      auto_create = current_dir_is_git_repo,
      -- This must be disabled; otherwise, closing all buffers and then closing Neovim would remove the theme data.
      auto_delete_empty_sessions = false, -- Enables/disables deleting the session if there are only unnamed/empty buffers when auto-saving
      save_extra_data = function(_)
        local colorscheme = vim.g.colors_name
        if not colorscheme then
          return
        end
        return vim.fn.json_encode {
          colorscheme = colorscheme,
        }
      end,
      restore_extra_data = function(_, extra_data)
        local json = vim.fn.json_decode(extra_data)
        if json.colorscheme then
          vim.cmd("colorscheme " .. json.colorscheme)
          vim.schedule(function()
            vim.cmd("colorscheme " .. json.colorscheme)
          end)
        end
      end,
    }
  end,
}
