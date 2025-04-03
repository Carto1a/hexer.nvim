local buffer = require("hexer.buffer")

---@class HexerBufferAddress: HexerBuffer
---@field private __index any
local M = setmetatable({}, { __index = buffer })
M.__index = M

---@private
function M:__tostring()
  return "HexerBufferAddress"
end

---@return HexerBufferAddress
function M:new()
  ---@type HexerBufferAddress
  local obj = setmetatable(buffer:new(false), self)

  return obj
end

---@param start_index integer
---@param end_index integer
---@param format HexerFormatOptions
function M:write_address(start_index, end_index, format)
  local octets_count_line = (format.group_of_bytes * format.grouped_bytes_per_row) / 2
  local format_string = "%0" .. format.address_length .. "x:"

  ---@type string[]
  local address_lines = {}
  for i = start_index, end_index do
    local address_integer = i * octets_count_line
    local address_hex = string.format(format_string, address_integer)

    table.insert(address_lines, address_hex)
  end

  vim.api.nvim_buf_set_lines(self.id, start_index, end_index, false, address_lines)
end

return M
