local win = require("hexer.window")

---@class HexerWinHex: HexerWin
local M = setmetatable({}, { __index = win })
M.__index = M

function M:__tostring()
  return "HexerWinHex"
end

---@param buf HexerBuffer|HexerBufferHex
---@return HexerWin|HexerWinHex
function M:new(buf)
  ---@cast buf HexerBuffer
  local obj = setmetatable(win:new("right", buf, 16, nil, true, "hexer", true), self)

  return obj
end

return M
