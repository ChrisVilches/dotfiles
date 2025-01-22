return {
  -- This plugins adds gb/gbc to comment as blocks (e.g. in C++ it uses /* */ instead of //)
  -- Can also be integrated with TreeSitter.
  "numToStr/Comment.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = true,
}
