local win = require("hexer.window")

---@class HexerWinHex: HexerWin
---@field private __index any
local M = setmetatable({}, { __index = win })
M.__index = M

---@private
function M:__tostring()
  return "HexerWinHex"
end

---@param buf HexerBufferHex
---@return HexerWinHex
function M:new(buf)
  ---@type HexerWinHex
  local obj = setmetatable(win:new("right", buf, 16, nil, true, "hexer", true), self)

  return obj
end

return M
