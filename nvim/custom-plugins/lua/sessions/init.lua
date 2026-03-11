-- Some settings, like filetypes and options, may persist in the session,
-- making them difficult to clear. To resolve this, you can either delete the
-- session file or reload your options after initializing the session to override
-- them.

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

local function save_session(path)
  local scheme = vim.g.colors_name or "default"

  vim.cmd("mksession! " .. vim.fn.fnameescape(path))
  vim.fn.writefile({
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

  vim.cmd("silent! source " .. vim.fn.fnameescape(session_path()))

  load_theme()
  handle_file_arglist(original_file_arglist)
end

-- File explorer or similar plugins often cannot be restored correctly, resulting in windows that appear empty.
-- This function closes all such empty windows to ensure a clean session restoration.
local function clean_empty_windows()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_get_name(buf) == "" and #vim.api.nvim_list_wins() > 1 then
      vim.api.nvim_win_close(win, true)
    end
  end
end

return {
  init = function()
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        save_session(session_path())
      end,
    })

    load_session()
    clean_empty_windows()
  end,
}
