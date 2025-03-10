local normal_bg = "#549438"
local insert_bg = "#ea3535"
local cmd_bg = "#bf9f00"
local white = "#ffffff"
local black = "#000000"

return {
  normal = {
    a = { fg = white, bg = normal_bg, gui = "bold" },
    b = { fg = white, bg = "#005f87" },
    c = { fg = white, bg = black },
  },
  insert = {
    a = { fg = white, bg = insert_bg, gui = "bold" },
  },
  visual = {
    a = { fg = white, bg = "#ff8700", gui = "bold" },
  },
  command = {
    a = { fg = white, bg = cmd_bg, gui = "bold" },
  },
}
