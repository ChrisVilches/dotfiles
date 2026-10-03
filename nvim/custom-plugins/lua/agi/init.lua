-- Runs the `agi` command line agent on the file of the current buffer.
--
-- The agent is spawned directly, without a shell, so nothing resolves PATH for
-- it: exepath() does that here and also tells us when the executable is missing.
--
-- Everything agi needs from the environment (AGI_BACKEND, OPENAI_URL,
-- OPENAI_KEY, ...) is inherited from the shell Neovim was started from, so no
-- variable is set here.
--
-- Piped (which is what we do), agi writes only its final answer to stdout and
-- its progress and errors to stderr.

local M = {}

-- Where this very file is. Lua marks a chunk loaded from a file with a source
-- of "@" and the path it was loaded from, which is the one place that knows
-- where the plugin ended up without anything having to agree on it beforehand:
-- no directory named twice, nothing to keep in step when the plugin is moved,
-- and no search of the runtimepath that a second copy of the plugin could win.
-- It is made absolute here and not where it is used, because the path a chunk
-- was loaded from can be relative to the working directory, and the working
-- directory is the user's to change at any moment.
local here = vim.fs.dirname(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p"))

M.config = {
  -- Name or full path of the agi executable. A bare name is looked up in PATH.
  executable = "agi",

  -- The system prompt agi runs on instead of its own generic one. It is part
  -- of the plugin rather than something the user supplies, so it is kept
  -- beside the code and found from there.
  system_prompt = vim.fs.joinpath(here, "system-prompt.md"),
}

local function location_description(line1, line2)
  if line1 == line2 then
    return string.format("The user had the cursor on line %d.", line1)
  end
  return string.format("The user selected lines %d to %d.", line1, line2)
end

local function build_prompt(path, line1, line2, task)
  return table.concat({
    string.format("You will act on this file: %s.", path),
    location_description(line1, line2),
    "The task may span other lines: these line numbers are only an approximation of where the user wants to work on.",
    string.format("The task the user defined is: %s", task),
  }, " ")
end

local function show_answer(answer)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "markdown"

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(vim.trim(answer), "\n", { plain = true }))
  vim.bo[buf].modifiable = false

  vim.cmd.split()
  vim.api.nvim_win_set_buf(0, buf)
  vim.wo[0].wrap = true

  for _, k in pairs { "q", "<esc>" } do
    vim.keymap.set("n", k, "<cmd>close<cr>", { buffer = buf, silent = true, nowait = true })
  end
end

-- A message cannot be taken back: the message area only ever holds the last
-- thing written to it, so the "running" line is removed by writing an empty
-- one over it when the run ends. These are not kept in :messages either, as
-- the progress of a finished run is of no interest.
local function status(text)
  vim.api.nvim_echo({ { text } }, false, {})
end

local function start(executable, path, line1, line2, task)
  status "agi: running..."

  local command = {
    executable,
    "--sys",
    M.config.system_prompt,
    build_prompt(path, line1, line2, task),
  }

  vim.system(command, { text = true }, vim.schedule_wrap(function(result)
    status ""

    if result.code ~= 0 then
      local reason = vim.trim(result.stderr or "")
      if reason == "" then
        reason = "exited with status " .. result.code
      end
      vim.notify("agi: " .. reason, vim.log.levels.ERROR)
      return
    end

    -- The agent may have edited files that are open, this one included.
    vim.cmd.checktime()
    show_answer(result.stdout)
  end))
end

-- Meant to be called from a user command defined with nargs and range, so opts
-- carries the prompt in args and the line range in line1/line2. Without a range
-- the two lines are both the cursor line, and without a prompt the user is
-- asked for one.
function M.run(opts)
  local executable = vim.fn.exepath(M.config.executable)

  if executable == "" then
    vim.notify("agi: executable not found: " .. M.config.executable, vim.log.levels.ERROR)
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(buf)

  if path == "" then
    vim.notify("agi: the current buffer has no file", vim.log.levels.ERROR)
    return
  end

  -- The agent reads and writes the file on disk, so unsaved changes would be
  -- invisible to it, and reloading the buffer afterwards would discard them.
  if vim.bo[buf].modified then
    vim.notify("agi: save the buffer before running", vim.log.levels.ERROR)
    return
  end

  local line1, line2 = opts.line1, opts.line2

  if vim.trim(opts.args) ~= "" then
    start(executable, path, line1, line2, opts.args)
    return
  end

  -- The lines are read before asking, because the prompt is answered later and
  -- the cursor may have moved by then.
  vim.ui.input({ prompt = "agi: " }, function(task)
    if task == nil or vim.trim(task) == "" then
      return
    end
    start(executable, path, line1, line2, task)
  end)
end

return M
