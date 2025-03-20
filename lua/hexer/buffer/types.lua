---@alias endianness "big-endian" | "little-endian"
---@alias encoding "ascii" | "utf-8"
---@alias address_type "hex" | "binary"

local M = {}

M.VALID_ENDIANNESS = {
  ["big-endian"] = true,
  ["little-endian"] = true,
}

M.VALID_ADDRESS_TYPE = {
  ["hex"] = true,
  ["binary"] = true,
}

M.VALID_ENCODING = {
  ["ascii"] = true,
  ["utf-8"] = true,
}

return M
