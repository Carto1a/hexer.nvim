local buffer = require("hexer.buffer")
local types = require("hexer.buffer.types")

---@class HexerBufferText: HexerBuffer
---@field endianness endianness
---@field encoding encoding
local M = setmetatable({}, { __index = buffer })

local validators = {
  encoding = function(value)
    if not types.VALID_ENCODING[value] then
      error("Invalid encoding: " .. tostring(value), 2)
    end
  end,

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
---@param encoding encoding
---@return HexerBuffer|HexerBufferText
function M:new(endianness, encoding)
  ---@type HexerBuffer|HexerBufferText
  local obj = setmetatable(buffer:new(false), self)

  obj.encoding = encoding or "ascii"
  obj.endianness = endianness or "big-endian"

  return obj
end

return M
