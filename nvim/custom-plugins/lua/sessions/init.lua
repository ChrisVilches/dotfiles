-- TODO: document that some things like options get hardcoded in the session file and then the only way to clear them up
-- is by removing the file (or by loading options.lua after the init(), etc).

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

-- TODO: I don't want to store folds.

-- NOTE:
-- Theme pickers preview colorschemes by temporarily applying them.
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
