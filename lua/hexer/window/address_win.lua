local win = require("hexer.window")

---@class HexerWinAddress: HexerWin
local M = setmetatable({}, { __index = win })
M.__index = M

function M:__tostring()
  return "HexerWinAddress"
end

---@param buf HexerBuffer|HexerBufferAddress
---@return HexerWin|HexerWinAddress
function M:new(buf)
  ---@cast buf HexerBuffer
  local obj = setmetatable(win:new("left", buf, 10, 10, false, "addres", true), self)

  return obj
end

return M
