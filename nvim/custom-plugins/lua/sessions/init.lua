-- TODO: sometimes the first buffer is an Oil view lol... wtf
-- Update: haven't been able to reproduce this lately. Maybe just remove.

-- TODO: options get overriden (even ones I explicitly set in options.lua)
-- but it seems this is the expected behavior so I'm not going to complain... maybe just document
-- it and/or create a function to reset them. Or have a configuration for options that are always
-- set AFTER the session is loaded. That'd be cool, but it also needs to get documented!!!!!
-- Update: I think this can be easily fixed by simply loading my options after the init. Both things are done manually
-- so I can control the order of things loading. But I still need to document these things!

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
-- I think this can be done by simply saving them and then let the user decide if they want to load options after
-- loading the session (to override them). This works (verified). I need to continue using the init() function called by the user.
-- TODO: tweak the vim.o.sessionoptions value here.
-- TODO: I don't want to store folds.

-- NOTE:
-- Telescope theme pickers preview colorschemes by temporarily applying them.
-- If a variant shares the same base name (e.g. "ayu-mirage" → "ayu"), the
-- preview may switch `vim.g.colors_name` to the base scheme without changing
-- the actual appearance. When the picker closes, Neovim may therefore believe
-- the active scheme is "ayu" instead of "ayu-mirage".
--
-- A workaround could ignore certain ColorScheme events, but this is unreliable:
-- depending on how the picker previews or restores themes, legitimate changes
-- may also be filtered out. Because of this ambiguity, the session simply saves
-- whatever `vim.g.colors_name` currently reports.
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

local function load_session()
  -- Save the argument list Neovim was opened with before the session file changes it when it's sourced.
  local original_file_arglist = get_file_arglist()

  local path = session_path()
  if vim.fn.filereadable(path) == 1 then
    vim.cmd("source " .. vim.fn.fnameescape(path))
    vim.cmd "%argdel"
  end

  load_theme()

  -- If Neovim was started with files in the arguments, use those instead of the ones stored in the session.
  handle_file_arglist(original_file_arglist)
end

return {
  init = function()
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        save_session(session_path())
      end,
    })

    load_session()
  end,
}
