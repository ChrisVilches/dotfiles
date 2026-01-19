local M = {}

-- TODO: options get overriden (even ones I explicitly set in options.lua)
-- but it seems this is the expected behavior so I'm not going to complain... maybe just document
-- it and/or create a function to reset them. Or have a configuration for options that are always
-- set AFTER the session is loaded. That'd be cool, but it also needs to get documented!!!!!

local function session_name_from_cwd()
  local cwd = vim.loop.cwd() or vim.fn.getcwd()
  -- turn /home/user/project into home__user__project
  local name = cwd:gsub("[/\\:]", "__")
  return name .. ".vim"
end

local function session_path()
  local dir = vim.fn.stdpath "data" .. "/sessions"
  vim.fn.mkdir(dir, "p")
  return dir .. "/" .. session_name_from_cwd()
end

-- TODO: shouldn't save some options!!!! specially ones that I can modify accidentally. Ok, but at least I can
-- easily debug what's being saved and tweak accordingly.
-- TODO: tweak the vim.o.sessionoptions value here.
-- TODO: I don't want to store folds.
local function save_session(path)
  local scheme = vim.g.colors_name or "default"

  vim.cmd("mksession! " .. vim.fn.fnameescape(path))
  vim.fn.writefile({
    "",
    "let g:session_colorscheme = '" .. scheme .. "'",
  }, path, "a")
end

local function get_theme()
  local default = "github_dark_dimmed"
  return vim.g.session_colorscheme or default
end

local function load_theme()
  local theme = get_theme()
  vim.cmd.colorscheme(theme)
  vim.schedule(function()
    vim.cmd.colorscheme(theme)
  end)
end

function M.load_session()
  local path = session_path()
  if vim.fn.filereadable(path) == 1 then
    vim.cmd("source " .. vim.fn.fnameescape(path))
  end

  load_theme()
end

function M.save_session()
  save_session(session_path())
end

return M
