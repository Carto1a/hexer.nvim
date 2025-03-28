local M = {}

---@class HexerFormatHexLineReturn
---@field buffer string
---@field lines string[]

---@param line string
---@param group_bytes_size integer
---@return string
local function group_bytes(line, group_bytes_size)
  assert(group_bytes_size > 1, "not a valid value to group_bytes_size")

  local group_capture_bytes = nil
  local group_capture_bytes_buffer = {}
  for i = 1, group_bytes_size do
    table.insert(group_capture_bytes_buffer, i, "%w")
  end
  group_capture_bytes = "(" .. table.concat(group_capture_bytes_buffer) .. ")"

  local formated_line = line:gsub(group_capture_bytes, "%1 "):gsub("%s$", "")
  return formated_line
end

---@param line string
---@param buffer string
---@param is_last_line boolean
---@param format HexerFormatOptions
---@return HexerFormatHexLineReturn
function M.format_hex_line(line, buffer, is_last_line, format)
  assert(line:len(), "nothing to format")

  ---@type HexerFormatHexLineReturn
  local return_value = {
    buffer = "",
    lines = {}
  }

  local line_buffer = buffer .. line
  local bytes_in_row = format.group_of_bytes * format.grouped_bytes_per_row

  local format_count = 0
  while true do
    local start_to_format = bytes_in_row * format_count + 1
    local end_to_format = bytes_in_row * (format_count + 1)
    local bytes_to_format = line_buffer:sub(start_to_format, end_to_format)

    if bytes_to_format:len() < bytes_in_row and not is_last_line then
      return_value.buffer = bytes_to_format
      break
    end

    local formated_line = group_bytes(bytes_to_format, format.group_of_bytes)
    table.insert(return_value.lines, formated_line)

    if is_last_line then
      break
    end

    format_count = format_count + 1
  end

  return return_value
end

return M
