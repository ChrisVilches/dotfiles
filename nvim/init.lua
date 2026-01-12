local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup {
  spec = { import = "plugins" },
  defaults = { lazy = true },
  change_detection = {
    enabled = false,
    notify = true,
  },
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

vim.schedule(function()
  require "options"
  require "autocmds"
  require "commands"
  require "mappings/editing"
  require "mappings/misc"
  require "mappings/navigation"
  require "mappings/telescope"

  -- The session plugin sets this variable (the plugin isn't lazy, so it happens before this)
  if not vim.g.session_colorscheme_loaded then
    local default_theme = "github_dark_dimmed"
    vim.cmd.colorscheme(default_theme)
    vim.schedule(function()
      vim.cmd.colorscheme(default_theme)
    end)
  end

  -- This is mainly to ensure Language Server Protocol (LSP) features,
  -- syntax highlighting, and the associated ftplugin (filetype plugin)
  -- are correctly loaded for these specific files.
  local custom_filetypes = {
    jbuilder = "ruby",
    rhtml = "rhtml",
  }

  for ext, ft in pairs(custom_filetypes) do
    vim.filetype.add { extension = { [ext] = ft } }
  end
end)
