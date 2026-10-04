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
--
-- Each file gets a conversation of its own, kept in a directory under the
-- system's temporary one and named after the file's path, so that asking for
-- one more thing about a file is asking it of an agent that remembers the last
-- few. The conversation lasts as long as the Neovim it was begun in: the
-- directory of a file first run on here is emptied before that run, whoever
-- left it behind.
--
-- Known quirk: the name follows the path, so renaming or moving a file leaves
-- its conversation behind under the old name, where nothing will look for it
-- again and the next Neovim will not clear it either. The new path simply
-- starts a conversation of its own, and the orphan stays until the temporary
-- directory is cleared, which is left as it is rather than paid for with
-- bookkeeping that would have to survive Neovim exiting.

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

-- The session directories handed out during this Neovim session, by file path.
-- A directory is only prepared once here, and every later run on the same file
-- continues the conversation already in it. A fresh Neovim gets a fresh table,
-- which is what makes a restart begin the conversation again.
local sessions = {}

-- Where agi keeps the conversation about a file. The name is derived from the
-- file's path alone, so the same file always lands on the same directory and a
-- directory can be traced back to the file it belongs to. Only the beginning of
-- the digest is used: the whole of it is far longer than this name has to be to
-- stay free of collisions. The system's temporary directory is asked for rather
-- than written down, as it is not /tmp everywhere.
local function session_path(path)
  return vim.fs.joinpath(vim.uv.os_tmpdir(), "nvim-agi-" .. vim.fn.sha256(path):sub(1, 12))
end

-- The directory to run agi in for a file, and whether the conversation in it
-- begins here. Whatever an earlier Neovim left behind under the same name is
-- removed before this one's first run on the file: agi reads an existing
-- directory as a conversation to carry on, so starting from nothing means
-- handing it an empty one.
local function session_for(path)
  local existing = sessions[path]
  if existing then
    return existing, false
  end

  local dir = session_path(path)
  vim.fn.delete(dir, "rf")
  vim.fn.mkdir(dir, "p")
  sessions[path] = dir
  return dir, true
end

-- The file as it is on disk, as the one string vim.diff() wants. The agent
-- works on the file rather than on the buffer, so disk is the only place both
-- the before and the after can be read from. Nothing is known here about the
-- line endings a file had, and nothing has to be: both snapshots are read the
-- same way, so whatever is lost is lost from both and never shows up as a
-- difference. A file that cannot be read has no content to compare and says so
-- with nil.
local function snapshot(path)
  if vim.fn.filereadable(path) == 0 then
    return nil
  end
  return table.concat(vim.fn.readfile(path), "\n") .. "\n"
end

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

-- Where a run's answer is kept. The answers of a conversation live together in
-- a directory of their own beside it, so that what was asked and what came back
-- can be read side by side, and so that nothing here is mistaken for part of
-- the record agi itself keeps. The name is the moment the answer arrived, which
-- orders the files the way the conversation went.
local function answer_path(session)
  local dir = vim.fs.joinpath(session, "answers")
  vim.fn.mkdir(dir, "p")
  return vim.fs.joinpath(dir, os.date "%Y-%m-%d_%H-%M-%S" .. ".md")
end

local function answer_lines(note, answer, diff)
  local lines = { note, "" }
  vim.list_extend(lines, vim.split(vim.trim(answer), "\n", { plain = true }))

  -- Under the answer, where it reads as the evidence for what the answer says
  -- was done, rather than above it as something to scroll past to reach the
  -- answer. A run that changed nothing has nothing to show here.
  if diff ~= "" then
    vim.list_extend(lines, { "", "```diff" })
    vim.list_extend(lines, vim.split(vim.trim(diff), "\n", { plain = true }))
    vim.list_extend(lines, { "```" })
  end

  return lines
end

-- The answer is written to a file and that file is opened, rather than being
-- poured into a scratch buffer. The point is to make no claim on the rest of
-- the configuration: a markdown file opened the ordinary way is understood by
-- whatever happens to be installed, this editor's own machinery included, and
-- by nothing in particular if nothing is installed.
--
-- The difference is not only tidiness. A buffer that is given its filetype
-- before it is shown has its FileType handled while it belongs to no window, so
-- Neovim runs that handling in a scratch window of its own making and throws
-- the window away afterwards. Buffer-local work survives that; window-local
-- work does not, and 'conceallevel' is window-local, which is exactly what
-- decides whether markup is rendered or left standing in the text. Opening a
-- file leaves the buffer in a real window for every step, so there is no such
-- window to lose anything to.
--
-- The note belongs above the answer rather than in the message area, where it
-- would be gone by the time the answer has been read. It names the directory so
-- that the conversation, and the rest of what agi recorded there, can be opened
-- and looked at.
local function show_answer(session, note, answer, diff)
  local path = answer_path(session)
  vim.fn.writefile(answer_lines(note, answer, diff), path)

  -- No swapfile for a file that is written once and only read, and nothing in
  -- the buffer list, as this is an answer rather than something being worked
  -- on. It is left unmodifiable for the same reason: editing it would change
  -- the record without changing anything it describes.
  vim.cmd("noswapfile split " .. vim.fn.fnameescape(path))

  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].buflisted = false
  vim.bo[buf].modifiable = false
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

  -- Read before the agent is given the chance to edit the file, and held only
  -- until the diff is computed from it when the run ends.
  local before = snapshot(path)

  local session, started = session_for(path)
  local note = string.format("*%s: `%s`*", started and "new session started" or "continued session", session)

  local command = {
    executable,
    "--sys",
    M.config.system_prompt,
    "--session",
    session,
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

    -- Only a run with both ends of the comparison in hand has anything to
    -- compare; an unchanged file gives an empty diff, which the window treats
    -- the same way as having none.
    local after = snapshot(path)
    -- vim.diff() gives no surrounding lines unless asked, and a hunk of bare
    -- additions and removals is hard to place in a file one is not holding in
    -- mind; three lines is what diffs are usually read with.
    local diff = (before and after) and vim.diff(before, after, { ctxlen = 3 }) or ""

    show_answer(session, note, result.stdout, diff)
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
