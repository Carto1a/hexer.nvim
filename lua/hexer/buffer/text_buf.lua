local buffer = require("hexer.buffer")
local types = require("hexer.buffer.types")

---@class HexerBufferText: HexerBuffer
---@field private endianness endianness
---@field private encoding encoding
---@field private decoder Decoder
---@field private __index any
local M = setmetatable({}, { __index = buffer })
M.__index = M

---@private
function M:__tostring()
  return "HexerBufferText"
end

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

---@private
function M:__newindex(key, value)
  local validator = validators[key]
  if validator then validator(value) end
  rawset(self, key, value)
end

---@param endianness endianness
---@param encoding encoding
---@return HexerBufferText
function M:new(endianness, encoding)
  local decoders = require("hexer.buffer.decoder_hex")

  ---@type HexerBufferText
  local obj = setmetatable(buffer:new(false), self)

  obj.encoding = encoding or "ascii"
  obj.endianness = endianness or "big-endian"

  local decoder = decoders[encoding]
  assert(decoders, "invalid decoders, bruh")
  obj.decoder = decoder

  return obj
end

---@param start_index integer
---@param end_index integer
---@param hex_lines string[]
---@param format HexerFormatOptions
function M:write_text_lines(start_index, end_index, hex_lines, format)
  local octets_count_line = (format.group_of_bytes * format.grouped_bytes_per_row) / 2

  ---@type string[]
  local text_lines = {}

  for _, value in pairs(hex_lines) do
    local text_line = self.decoder.decode(value)
    table.insert(text_lines, text_line)
  end

  vim.api.nvim_buf_set_lines(self.id, start_index, end_index, false, text_lines)
end

return M
