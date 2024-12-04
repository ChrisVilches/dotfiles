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

-- TODO: The theme loads wrong sometimes.
-- How to reproduce: Set catppuccin-macchiato to daijob5 project
-- re-open project. The icons in the tabs look a bit wrong.
-- Change to next theme, and then to previous one to go back to catppuccin-macchiato,
-- and it will look good.
local theme = require("utils").load_theme()

if theme ~= nil then
  if not pcall(function()
    vim.cmd("colorscheme " .. theme)
  end) then
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
