return {
  -- TODO: I don't know exactly what this plugin does, so I'm gonna disable it for now.
  -- research what it does.
  "numToStr/Comment.nvim",
  enabled = false,
  -- event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "JoosepAlviste/nvim-ts-context-commentstring",
  },
  config = function()
    local comment = require "Comment"
    local ts_context_commentstring = require "ts_context_commentstring.integrations.comment_nvim"
    comment.setup {
      pre_hook = ts_context_commentstring.create_pre_hook(),
    }
  end,
}
