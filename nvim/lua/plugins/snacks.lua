local function move(n, key)
  return function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(n .. key, true, false, true), "n", false)
  end
end

-- TODO: amazing... maybe I can just stop using Oil and Telescope and just use this one lol...
-- move this plugin to its own directory.
-- But I think telescope is good enough for searching.
-- command_history is better on Snacks (GUI is nicer and commands are highlighted)
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  -- TODO: Experiment enabling more widgets.
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    -- bigfile = { enabled = true },
    -- dashboard = { enabled = true },
    explorer = {
      enabled = true,
      keys = {
        ["<C-j>"] = move(6, "j"),
        ["<C-k>"] = move(6, "k"),
      },
    },
    indent = {
      enabled = true, -- enable indent guides
      animate = {
        enabled = false,
      },
      filter = function(buf)
        if vim.bo[buf].filetype == "markdown" then
          return false
        end

        return vim.g.snacks_indent ~= false and vim.b[buf].snacks_indent ~= false and vim.bo[buf].buftype == ""
      end,
    },
    input = { enabled = true },
    picker = {
      win = {
        input = {
          keys = {
            ["<C-j>"] = move(6, "j"),
            ["<C-k>"] = move(6, "k"),
          },
        },
        list = {
          keys = {
            ["<C-j>"] = move(6, "j"),
            ["<C-k>"] = move(6, "k"),
          },
        },
      },
    },
    -- picker = { enabled = true },
    -- notifier = { enabled = true },
    -- quickfile = { enabled = true },
    -- scope = { enabled = true },
    -- scroll = { enabled = true },
    -- statuscolumn = { enabled = true },
    -- words = { enabled = true },
  },
}
