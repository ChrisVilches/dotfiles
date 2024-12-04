-- retroblue.lua
-- TODO: These names say nothing in practice. I use them all over the place.
-- TODO: Colors are a mess. I have several colors repeated, and sometimes tweaked slightly, which means
-- I'm not recycling a small palette of colors.
local colors = {
  -- bg = "#07008f",
  -- bg = "#0e0791",
  bg = "#0e078c",
  fg = "#bbeded",
  -- accent = "#e17de3",
  -- accent = "#b55fc2",
  accent = "#6ab567",
  error = "#b51b1b",
  warning = "#f5f056",
  info = "#87CEEB",
  cursor = "#ebeef2",
  visual_bg = "#22706c",
  -- visual_bg = "#1e8f89",
  comments = "#888888",
  keyword = "#76b4de",
}

-- • {val}    Highlight definition map, accepts the following keys:
-- • fg: color name or "#RRGGBB", see note.
-- • bg: color name or "#RRGGBB", see note.
-- • sp: color name or "#RRGGBB"
-- • blend: integer between 0 and 100
-- • bold: boolean
-- • standout: boolean
-- • underline: boolean
-- • undercurl: boolean
-- • underdouble: boolean
-- • underdotted: boolean
-- • underdashed: boolean
-- • strikethrough: boolean
-- • italic: boolean
-- • reverse: boolean
-- • nocombine: boolean
-- • link: name of another highlight group to link to, see
--   |:hi-link|.
-- • default: Don't override existing definition |:hi-default|
-- • ctermfg: Sets foreground of cterm color |ctermfg|
-- • ctermbg: Sets background of cterm color |ctermbg|
-- • cterm: cterm attribute map, like |highlight-args|. If not
--   set, cterm attributes will match those from the attribute
--   map documented above.
-- • force: if true force update the highlight group when it
--   exists.

local function set_highlights()
  local function hi(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- General UI
  hi("Normal", { fg = colors.fg, bg = colors.bg })
  hi("CursorLine", { bg = colors.accent })
  hi("Visual", { bg = colors.visual_bg })
  hi("Search", { bg = colors.warning, fg = colors.bg })
  hi("Error", { fg = colors.bg, bg = colors.error })
  hi("WarningMsg", { fg = colors.warning })
  hi("InfoMsg", { fg = colors.info })
  hi("CursorLineNr", { fg = colors.cursor, bold = true })
  hi("LineNr", { fg = colors.comments })

  -- Try to manipulate Lualine (lualine's auto theme uses my colors to try to setup colors for lualine)
  hi("StatusLine", { bg = "#000000" }) -- Without this, lualine looks horrible
  hi("Special", { fg = "#fff4b3" }) -- Affects the {} (braces)
  hi("PMenuSel", { fg = "#2ca832", bg = "#5fc262" }) -- Affects the NORMAL in Lualine (fg affects tabs)
  hi("Identifier", { fg = "#98b5d4", italic = true }) -- This affects the "fg" in the table (lua)

  -- Change NVIM Tree colors.
  hi("NvimTreeNormal", { fg = "#e0dbba", bg = "#030052" })
  hi("NvimTreeCursorLine", { fg = "#cfcfcf", bg = "#302878" })
  -- NOTE: There are several other colors that one can tweak, but for now this is enough.
  -- hi("NvimTreeNormalFloat", { fg = "#ff0000", bg = "#030052" })
  -- hi("NvimTreeNormalNC", { fg = "#ff0000", bg = "#030052" })
  -- hi("NvimTreeLineNr", { fg = "#ff0000", bg = "#030052" })
  -- hi("NvimTreeWinSeparator", { fg = "#2e2e2e" })
  -- hi("NvimTreeEndOfBuffer", { fg = "#ff0000", bg = "#030052" })
  -- hi("NvimTreePopup", { fg = "#ff0000", bg = "#030052" })
  -- hi("NvimTreeSignColumn", { fg = "#ff0000", bg = "#030052" })
  -- hi("NvimTreeCursorColumn", { fg = "#ff0000", bg = "#030052" })
  -- hi("NvimTreeCursorLineNr", { fg = "#ff0000", bg = "#030052" })
  -- hi("NvimTreeStatusLine", { fg = "#ff0000", bg = "#030052" })
  -- hi("NvimTreeStatusLineNC", { fg = "#ff0000", bg = "#030052" })
  -- hi("NvimTreeExecFile", { fg = "#a3a7b5", bg = "#030052" })
  -- hi("NvimTreeImageFile", { fg = "#a3a7b5", bg = "#030052" })
  -- hi("NvimTreeSpecialFile", { fg = "#a3a7b5", bg = "#030052" })
  -- hi("NvimTreeSymlink", { fg = "#a3a7b5", bg = "#030052" })
  -- hi("NvimTreeRootFolder", { fg = "#a3a7b5", bg = "#030052" })
  -- hi("NvimTreeFolderName", { fg = "#9c9c9c", bg = "#030052" })
  -- hi("NvimTreeEmptyFolderName", { fg = "#a3a7b5", bg = "#030052" })
  -- hi("NvimTreeOpenedFolderName", { fg = "#a3a7b5", bg = "#030052" })
  -- hi("NvimTreeSymlinkFolderName", { fg = "#a3a7b5", bg = "#030052" })

  -- Syntax
  -- hi("Comment", { fg = colors.comments, italic=true })
  -- hi("Keyword", { fg = colors.keyword, bold = true })
  -- hi("Function", { fg = colors.cursor })

  -- TreeSitter highlighting.
  -- You can add more TreeSitter highlights using this.
  -- https://neovim.io/doc/user/treesitter.html#_treesitter-syntax-highlighting
  hi("@type", { fg = "#cbd4d3", bold = true })
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
  -- hi("@boolean", { fg = "#bee6d8", italic = true })
  hi("@string", { fg = colors.accent, bold = true })
  hi("@character", { fg = colors.accent, bold = true })

  -- Diagnostic
  local diagnostics = {
    error = "#b51b1b",
    warning = "#d16c00",
    info = "#6792bf",
  }

  -- This one appears when there's an obvious syntax error.
  hi("DiagnosticError", { fg = "#ffffff", bg = diagnostics.error })
  -- This can be reproduced in C++ by having a function that returns an "int" not return anything.
  hi("DiagnosticWarn", { fg = "#ffffff", bg = diagnostics.warning })
  -- This one in Lua shows when defining a local variable without "local" and with "lowercase initial"
  -- (I think it expects global variables to be capitalized)
  hi("DiagnosticInfo", { fg = "#ffffff", bg = diagnostics.info })
  -- This one is when a variable is unused in Lua (doesn't show in C++)
  hi("DiagnosticHint", { fg = "#ffffff", bg = diagnostics.info })
end

-- Activate the colorscheme
local function load_colorscheme()
  vim.cmd "highlight clear"
  if vim.fn.exists "syntax_on" then
    vim.cmd "syntax reset"
  end
  vim.o.termguicolors = true
  vim.g.colors_name = "retroblue" -- Required for :colorscheme
  set_highlights()
end

-- Expose the colorscheme for Neovim
return load_colorscheme()
