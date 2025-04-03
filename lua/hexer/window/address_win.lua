local win = require("hexer.window")

---@class HexerWinAddress: HexerWin
---@field private __index any
local M = setmetatable({}, { __index = win })
M.__index = M

---@private
function M:__tostring()
  return "HexerWinAddress"
end

---@param buf HexerBufferAddress
---@return HexerWinAddress
function M:new(buf)
  ---@type HexerWinAddress
  local obj = setmetatable(win:new("left", buf, 10, 10, false, "addres", true), self)

  return obj
end

return M
