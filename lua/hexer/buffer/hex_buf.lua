local buffer = require("hexer.buffer")
local types = require("hexer.buffer.types")

---@class HexerBufferHex: HexerBuffer
---@field endianness endianness
local M = setmetatable({}, { __index = buffer })
M.__index = M

function M:__tostring()
  return "HexerBufferHex"
end

local validators = {
  endianness = function(value)
    if not types.VALID_ENDIANNESS[value] then
      error("Invalid endianness: " .. tostring(value), 2)
    end
  end
}

function M:__newindex(key, value)
  local validator = validators[key]
  if validator then validator(value) end
  rawset(self, key, value)
end

---@param endianness endianness
---@return HexerBuffer|HexerBufferHex
function M:new(endianness)
  ---@type HexerBuffer|HexerBufferHex
  local obj = setmetatable(buffer:new(true), self)

  obj.endianness = endianness or "big-endian"

  return obj
end

return M
