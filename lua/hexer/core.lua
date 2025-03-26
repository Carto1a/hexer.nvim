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


--- TODO: não estou retornado o resto, o buffer para a proxima kk

---@param line string
---@param buffer string
---@param format HexerFormatOptions
---@return HexerFormatHexLineReturn
function format_hex_line(line, buffer, format)
  -- 60
  ---@type HexerFormatHexLineReturn
  local return_value = {
    buffer = "",
    lines = {}
  }

  local line_to_format = buffer .. line

  local group_capture_bytes = nil
  local group_capture_bytes_buffer = {}
  for i = 1, format.group_of_bytes do
    table.insert(group_capture_bytes_buffer, i, "%w")
  end
  group_capture_bytes = "(" .. table.concat(group_capture_bytes_buffer) .. ")"

  local size_group_bytes = format.group_of_bytes * format.grouped_bytes_per_row
  local chars_to_format = line_to_format:sub(1, size_group_bytes)
  local format_count = 1
  while true do
    if chars_to_format == "" or not chars_to_format then
      break
    end

    local formated_line = chars_to_format:gsub(group_capture_bytes, "%1 ")
    table.insert(return_value.lines, formated_line)

    chars_to_format = line_to_format:sub(size_group_bytes * format_count, size_group_bytes * format_count + 1)
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

  local group_capture_bytes = nil
  local group_capture_bytes_buffer = {}
  for i = 1, format.group_of_bytes do
    table.insert(group_capture_bytes_buffer, i, "%w")
  end
  group_capture_bytes = "(" .. table.concat(group_capture_bytes_buffer) .. ")"

  local i = 0
  ---@type HexerFormatHexLineReturn
  local formated = { lines = {}, buffer = "" }
  for line in result.stdout:gmatch("[^\r\n]+") do
    formated = format_hex_line(line, formated.buffer, format)
    vim.api.nvim_buf_set_lines(buf_to_write, i, i, false, formated.lines)
    i = i + 1
  end
end

return M
