local buffer = require("hexer.buffer")
local types = require("hexer.buffer.types")

---@class HexerBufferAddress: HexerBuffer
---@field id integer
---@field address_type address_type
local M = setmetatable({}, { __index = buffer })

local validators = {
  address_type = function(value)
    if not types.VALID_ADDRESS_TYPE[value] then
      error("Invalid address type: " .. tostring(value), 2)
    end
  end
}

function M:__newindex(key, value)
  local validator = validators[key]
  if validator then validator(value) end
  rawset(self, key, value)
end

---@param address_type address_type
---@return HexerBuffer|HexerBufferAddress
function M:new(address_type)
  ---@type HexerBuffer|HexerBufferAddress
  local obj = setmetatable(buffer:new(false), self)

  obj.address_type = address_type or "hex"

  return obj
end

return M
