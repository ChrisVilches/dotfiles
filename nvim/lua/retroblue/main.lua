local function hi(group, opts)
  -- For more:
  -- :h nvim_set_hl
  vim.api.nvim_set_hl(0, group, opts)
end

local blue_bg = {
  "#070343",
  "#09055b",
  "#0c0674",
  "#0e078c",
  "#1008a4",
  "#1309bd",
  "#150bd5",
}

local function set_general_ui(opts)
  local use_darker = opts.darker
  local blue_idx
  -- Change the index for more/less blue.
  -- 4 is the OG one.
  if use_darker then
    blue_idx = 2
  else
    blue_idx = 4
  end

  local colors = {
    bg = blue_bg[blue_idx],
    error = "#ff0000",
    warning = "#f5f056",
    info = "#87CEEB",
    cursor = "#ebeef2",
    visual_bg = "#22706c",
    keyword = "#76b4de",
  }

  -- TODO: Some of these colors are untested.
  hi("Normal", { fg = colors.fg, bg = colors.bg })
  hi("Visual", { bg = colors.visual_bg })
  hi("Search", { bg = "#ffed82", fg = "#000000" })
  hi("Error", { fg = "#ff0000", bg = colors.error })
  hi("WarningMsg", { fg = colors.warning })
  hi("InfoMsg", { fg = colors.info })
  hi("CursorLineNr", { fg = colors.cursor, bold = true })
  hi("LineNr", { fg = "#3A6289" })
end

local function set_nvim_tree()
  -- Change NVIM Tree colors.
  -- local bg = "#0d242e"
  local bg = blue_bg[1]
  local file = "#e0dbba"

  -- For more:
  -- :h nvim-tree-highlight
  hi("NvimTreeNormal", { fg = file, bg = bg })
  hi("NvimTreeCursorLine", { fg = "#cfcfcf", bg = "#302878" })
  hi("NvimTreeFolderName", { fg = "#99BBC9" })
  hi("NvimTreeOpenedFolderName", { fg = "#99BBC9" })
  hi("NvimTreeWinSeparator", { fg = bg })
end

local function set_treesitter()
  local str = "#6ab567"
  local comments = "#777777"

  -- For more:
  -- https://neovim.io/doc/user/treesitter.html#_treesitter-syntax-highlighting
  hi("@type", { fg = "#cbd4d3", bold = true })
  -- On C++, this highlights "auto", "int", "bool", but not "vector<>" or "pair<>"
  hi("@type.builtin", { fg = "#ebe834" })
  -- NULL (C++) or nil (Lua), etc.
  hi("@constant.builtin", { fg = "#ebe834", italic = true })
  hi("@variable", { fg = "#dddddd" })
  hi("@punctuation.special", { fg = "#ff0000" })
  hi("@punctuation.delimiter", { fg = "#c8d3db" })
  hi("@punctuation.bracket", { fg = "#ffa033" })
  hi("@operator", { fg = "#7ea37e" })
  hi("@keyword", { fg = "#e0be12" })
  hi("@keyword.conditional", { fg = "#e0be12", italic = true })
  hi("@variable.builtin", { fg = "#d65f4f" })
  hi("@function", { fg = "#94a6a5" })
  hi("@number", { fg = "#d6a8f7" })
  hi("@boolean", { fg = "#d6a8f7", italic = true })
  hi("@string", { fg = str, bold = true })
  hi("@character", { fg = str, bold = true })
  hi("@comment", { fg = comments })
  hi("@property", { fg = "#d0d0d0", italic = true })
end

local function set_diagnostics()
  local error = "#b51b1b"
  local warning = "#d16c00"
  local info = "#6792bf"
  local text = "#ffffff"

  -- Obvious syntax error
  hi("DiagnosticError", { fg = text, bg = error })

  -- This can be reproduced in C++ by having a function that returns an "int" not return anything.
  hi("DiagnosticWarn", { fg = text, bg = warning })

  -- This one in Lua shows when defining a local variable without "local" and with "lowercase initial"
  -- (I think it expects global variables to be capitalized)
  hi("DiagnosticInfo", { fg = text, bg = info })

  -- This one is when a variable is unused in Lua (doesn't show in C++)
  hi("DiagnosticHint", { fg = text, bg = info })
end

local function load_colorscheme(variant)
  vim.cmd "highlight clear"
  if vim.fn.exists "syntax_on" then
    vim.cmd "syntax reset"
  end
  vim.o.termguicolors = true
  vim.g.colors_name = variant

  -- Lualine is loaded from lua/lualine/themes/<colorscheme_name>.lua
  set_general_ui { darker = variant == "retroblue-darker" }
  set_nvim_tree()
  set_treesitter()
  set_diagnostics()
end

return load_colorscheme
