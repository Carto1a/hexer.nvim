local buffer = require("hexer.buffer")
local types = require("hexer.buffer.types")

---@class HexerBufferHex: HexerBuffer
---@field private endianness endianness
---@field private __index any
---@field private cursor_hl integer
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
  local core = require("hexer.core")

  ---@type HexerBufferHex
  local obj = setmetatable(buffer:new(true), self)

  obj.endianness = endianness or "big-endian"
  obj.cursor_hl = vim.api.nvim_buf_set_extmark(obj.id, core.namespace, 0, 0, {})

  return obj
end

---@param row integer
---@param col integer
function M:hl(row, col)
  local namespace = require("hexer.core").namespace
  local format = require("hexer").cfg.format

  ---@param col_pos integer
  ---@param end_col integer
  local hl_octet = function(col_pos, end_col)
    vim.api.nvim_buf_set_extmark(
      self.id,
      namespace,
      row - 1,
      col_pos,
      {
        id = self.cursor_hl,
        hl_group = "HexerBufferHexOctet",
        end_col = end_col,
      })
  end

  local group_more_space = format.group_of_bytes + 1
  local group_index = (col + 1) / group_more_space
  local is_float = group_index % 1 ~= 0

  local pair = bit.band(col + 1 - math.floor(group_index), 1)

  if not is_float then
    vim.api.nvim_buf_del_extmark(self.id, namespace, self.cursor_hl)
    return
  end

  if pair == 1 then
    hl_octet(col, col + 2)
  else
    hl_octet(col - 1, col + 1)
  end
end

function M:write_hex_lines(lines, start_index, end_index)
  vim.api.nvim_buf_set_lines(self.id, start_index, end_index, false, lines)
end

return M
