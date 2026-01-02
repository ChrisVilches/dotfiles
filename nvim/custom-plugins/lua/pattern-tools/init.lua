local M = {}

local util = require "pattern-tools.util"

function M.find_and_replace_line()
  util.feed_keys [[:s///g<Left><Left><Left>]]
end

function M.find_and_replace_global()
  util.feed_keys [[:%s///g<Left><Left><Left>]]
end

function M.find_and_replace_selected()
  util.feed_keys [[:s///g<Left><Left><Left>]]
end

function M.find_and_replace_global_confirm()
  util.feed_keys [[:%s///gc<Left><Left><Left><Left>]]
end

return M
