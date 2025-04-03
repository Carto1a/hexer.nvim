local win = require("hexer.window")

---@class HexerWinText: HexerWin
---@field private __index any
local M = setmetatable({}, { __index = win })
M.__index = M

---@private
function M:__tostring()
  return "HexerWinText"
end

---@param buf HexerBufferText
---@return HexerWinText
function M:new(buf)
  ---@type HexerWinText
  local obj = setmetatable(win:new("right", buf, 16, 16, true, "text", true), self)

  return obj
end

return M
