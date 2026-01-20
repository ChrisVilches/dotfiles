local M = {}

-- TODO: sometimes the first buffer is an Oil view lol... wtf

-- TODO: don't know how to reproduce this consistently, but it's keeping a file in the arglist, and it doesn't go away
-- (in memos repo, it's the file add-note.sh)

-- TODO: Maybe try to do all the usage I do in nvim/init.lua inside the setup (or config=true) of this plugin
-- so that it's executed automatically.
--
-- TODO: works bad with my command "wn some-note", it should just open the file I told it to, maybe I should disable
-- using sessions in that case, but I still want to load the theme. This requires some careful consideration on how to implement it.

-- TODO: options get overriden (even ones I explicitly set in options.lua)
-- but it seems this is the expected behavior so I'm not going to complain... maybe just document
-- it and/or create a function to reset them. Or have a configuration for options that are always
-- set AFTER the session is loaded. That'd be cool, but it also needs to get documented!!!!!

local function session_name_from_cwd()
  local cwd = vim.fn.getcwd()
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

-- The theme is loaded twice because some plugins don't work well with just one load (such as the tabs plugin).
-- It's probably some kind of glitch.
local function load_theme()
  local theme = get_theme()
  vim.cmd.colorscheme(theme)
  vim.cmd.colorscheme(theme)
end

local function get_file_arglist()
  local list = vim.fn.argv()
  ---@cast list string[]
  return list
end

-- Opens a list of file arguments in Neovim, editing the first and adding the rest to the buffer list.
local function handle_file_arglist(file_arglist)
  for i, file in ipairs(file_arglist) do
    if i == 1 then
      vim.cmd("edit " .. vim.fn.fnameescape(file))
    else
      vim.cmd("badd " .. vim.fn.fnameescape(file))
    end
  end
end

-- TODO: a method to debug the session file would be nice, but considering that I'm doing a lot of custom
-- logic outside of that file, it would be meaningless, since some things wouldn't be clear as to why they
-- are happening simply by looking at the session file. Maybe try editing the session file itself? That'd
-- be very awkward and weird though (and perhaps even harder to debug from the code side).

function M.load_session()
  -- Save the argument list Neovim was opened with before the session file changes it when it's sourced.
  local original_file_arglist = get_file_arglist()

  local path = session_path()
  if vim.fn.filereadable(path) == 1 then
    vim.cmd("source " .. vim.fn.fnameescape(path))

    -- TODO: Experimental: I find it weird that the arguments get stuck in the session. But I'm not sure
    -- what are some other side effects of doing this. Like, in which situations would this be an issue, or
    -- have some unintended effects??????
    vim.cmd "%argdel"
  end

  load_theme()

  -- If Neovim was started with files in the arguments, use those instead of the ones stored in the session.
  handle_file_arglist(original_file_arglist)
end

function M.save_session()
  save_session(session_path())
end

return M
