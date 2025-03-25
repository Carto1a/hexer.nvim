local buffer = require("hexer.buffer")

---@class HexerBufferAddress: HexerBuffer
local M = setmetatable({}, { __index = buffer })
M.__index = M

function M:__tostring()
  return "HexerBufferAddress"
end

---@return HexerBuffer|HexerBufferAddress
function M:new()
  ---@type HexerBuffer|HexerBufferAddress
  local obj = setmetatable(buffer:new(false), self)

  return obj
end

return M
