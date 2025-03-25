local win = require("hexer.window")

---@class HexerWinText: HexerWin
local M = setmetatable({}, { __index = win })
M.__index = M

function M:__tostring()
  return "HexerWinText"
end

---@param buf HexerBuffer|HexerBufferText
---@return HexerWin|HexerWinText
function M:new(buf)
  ---@cast buf HexerBuffer
  local obj = setmetatable(win:new("right", buf, 16, 16, true, "text", true), self)

  return obj
end

return M
