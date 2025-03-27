---@class Hexer
local M = {}

-- NOTE: to com preguiça de arruma os parsers, depois faço isso

---@param data string[]
---@return HexerParsedLine[]
local function parser(data)
  local parsed_lines = {}
  local index = 1
  for line in pairs(data) do
    local parsed_line = {}

    parsed_line.address = string.sub(line, 1, 8)
    parsed_line.hex = string.sub(line, 11, 49)
    parsed_line.text = string.sub(line, 52, 68)

    parsed_lines[index] = parsed_line
    index = index + 1
  end

  return parsed_lines
end

---@param path string
---@return HexerParsedLine[]
local function parser_file(path)
  local result = vim.system({ 'xxd', path }, { text = true }):wait()

  local parsed_lines = {}
  local index = 1
  for line in string.gmatch(result.stdout, "\n") do
    local parsed_line = {}

    parsed_line.address = string.sub(line, 1, 8)
    parsed_line.hex = string.sub(line, 11, 49)
    parsed_line.text = string.sub(line, 52, 68)

    parsed_lines[index] = parsed_line
    index = index + 1
  end

  return parsed_lines
end

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
local function format_hex_line(line, buffer, is_last_line, format)
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

---@param buf? integer
---@param buf_to_write integer
---@param format HexerFormatOptions
function M.dump_buf_to(buf, buf_to_write, format)
  buf = buf or 0

  local cmd = { "xxd", "-p" }
  local cmd_system = vim.system(cmd, { text = true, stdin = true })
  local chunk_size = 10000

  local total_lines = vim.api.nvim_buf_line_count(buf)
  for i = 0, total_lines, chunk_size do
    local line_to_read = math.min(i + chunk_size, total_lines)
    local lines = vim.api.nvim_buf_get_lines(buf, i, line_to_read, false)
    cmd_system:write(table.concat(lines, "\n") .. "\n")
  end

  -- close stdin
  cmd_system:write(nil)
  local result = cmd_system:wait()

  assert(result.code, "code: ", result.code)
  assert(result.stdout, "no data in stdout, maybe buffer is empty")

  local i = 0
  ---@type HexerFormatHexLineReturn
  local formated = { lines = {}, buffer = "" }
  local last_line = ""
  for line in result.stdout:gmatch("[^\r\n]+") do
    formated = format_hex_line(line, formated.buffer, false, format)
    last_line = formated.buffer
    local formated_lines_count = #formated.lines
    vim.api.nvim_buf_set_lines(buf_to_write, i, i + formated_lines_count - 1, false, formated.lines)

    i = i + 1 + formated_lines_count - 1
  end

  formated = format_hex_line(last_line, "", true, format)
  vim.api.nvim_buf_set_lines(buf_to_write, i, i, false, formated.lines)
end

return M
