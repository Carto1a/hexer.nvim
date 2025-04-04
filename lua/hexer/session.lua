---@class HexerSession
---@field win_hex HexerWinHex
---@field win_address HexerWinAddress
---@field win_text HexerWinText
---@field loaded boolean
---@field hidden boolean
---@field modified fun(self: HexerSession): boolean
local M = {}
M.__index = M

---@private
function M:__tostring()
  return "HexerSession"
end

---@param format HexerFormatOptions
---@return HexerSession
function M:new(format)
  local utils = require("hexer.utils")
  local uuid = utils.generate_uuid()

  local buffer_hex = require("hexer.buffer.hex_buf")
  local buffer_text = require("hexer.buffer.text_buf")
  local buffer_address = require("hexer.buffer.address_buf")

  local window_hex = require("hexer.window.hex_win")
  local window_text = require("hexer.window.text_win")
  local window_address = require("hexer.window.address_win")

  local buf_hex = buffer_hex:new(format.endianness)
  local buf_text = buffer_text:new(format.endianness, format.encoding)
  local buf_address = buffer_address:new()

  local win_hex = window_hex:new(buf_hex)
  local win_text = window_text:new(buf_text)
  local win_address = window_address:new(buf_address)

  win_hex.indetifier = uuid
  win_address.indetifier = uuid
  win_text.indetifier = uuid

  ---@type HexerSession
  local obj = setmetatable({
    loaded = false,
    hidden = true
  }, self)

  obj.win_address = win_address
  obj.win_hex = win_hex
  obj.win_text = win_text

  return obj
end

function M:modified()
  return vim.api.nvim_get_option_value("modified", { buf = self.win_hex.buf.id })
end

return M
