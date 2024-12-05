vim.g.mapleader = " "

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup {
  spec = { import = "plugins" },
  defaults = { lazy = true },
  performance = {
    rtp = {
      disabled_plugins = {
        "2html_plugin",
        "tohtml",
        "getscript",
        "getscriptPlugin",
        "gzip",
        "logipat",
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "matchit",
        "tar",
        "tarPlugin",
        "rrhelper",
        "spellfile_plugin",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
        "tutor",
        "rplugin",
        "syntax",
        "synmenu",
        "optwin",
        "compiler",
        "bugreport",
        "ftplugin",
      },
    },
  },
}

local theme = require("utils").load_theme()

if theme ~= nil then
  if
    not pcall(function()
      -- If I only execute colorscheme once, the tab styles get messed up.
      -- A hacky workaround is to execute it twice.
      -- https://www.reddit.com/r/neovim/comments/11m9f02/new_to_nvim_and_lua_having_a_bit_of_an_issue_with/
      -- read this reddit.
      -- It seems the problem is because of the order in which plugins load.
      vim.cmd("colorscheme " .. theme)
      vim.schedule(function()
        vim.cmd("colorscheme " .. theme)
      end)
    end)
  then
    require "notify"(string.format("Theme %q not found", theme), "error")
  end
else
  require "notify"("No theme", "error")
end

vim.schedule(function()
  require "autocmds"
  require "commands"
  require "mappings/editing"
  require "mappings/misc"
  require "mappings/navigation"
  require "mappings/telescope"
  require "mappings/themes"
  require "options"
end)
