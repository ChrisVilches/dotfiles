return {
  -- TODO: ruby activates linting but the notifying thingy starts appearing
  -- on tabs for any other language as well. It should only work for the specified
  -- formats, not for other formats. How to reproduce: There's a difference before and
  -- after opening a Ruby buffer.
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  ft = { "ruby" },
  config = function()
    require("lint").linters_by_ft = {
      ruby = { "rubocop" },
    }

    -- TODO: This configuration isn't very good. Watch some tutorials or something.

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      callback = function()
        require("lint").try_lint()
        -- require "notify" "Linting"
      end,
    })
  end,
}
