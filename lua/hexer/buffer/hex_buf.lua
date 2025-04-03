local buffer = require("hexer.buffer")
local types = require("hexer.buffer.types")

---@class HexerBufferHex: HexerBuffer
---@field private endianness endianness
---@field private __index any
local M = setmetatable({}, { __index = buffer })
M.__index = M

---@private
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

---@private
function M:__newindex(key, value)
  local validator = validators[key]
  if validator then validator(value) end
  rawset(self, key, value)
end

---@param endianness endianness
---@return HexerBufferHex
function M:new(endianness)
  ---@type HexerBufferHex
  local obj = setmetatable(buffer:new(true), self)

  obj.endianness = endianness or "big-endian"

  return obj
end

function M:write_hex_lines(lines, start_index, end_index)
  vim.api.nvim_buf_set_lines(self.id, start_index, end_index, false, lines)
end

return M
