require("hexer.buffer")

---@class Hexer
---@field buffers { [integer]: HexerBuffer }
local M = {
  buffers = {}
}

---@param line string
---@return HexerParsedLine
local function parser(line)
  assert(type(line) == "string", "line is not a string")

  ---@type HexerParsedLine
  local parsed_line = {}

  parsed_line.address = string.sub(line, 1, 8)
  parsed_line.hex = string.sub(line, 11, 49)
  parsed_line.text = string.sub(line, 52, 68)

  return parsed_line
end

---@param buf integer
---@return HexerParsedLine[]
function M.dump(buf)
  buf = buf or 0

  vim.api.nvim_buf_call(buf, function()
    vim.cmd([[%!]] .. "xxd")
  end)

  local lines_total = vim.api.nvim_buf_line_count(buf)

  local lines = vim.api.nvim_buf_get_lines(buf, 0, lines_total, false)

  ---@type HexerParsedLine[]
  local parsed_lines = {}
  for index, line in ipairs(lines) do
    local parsed_line = parser(line)
    parsed_lines[index] = parsed_line
  end

  return parsed_lines
end

---@param hex_buf HexerBuffer
function M.add_buffer(hex_buf)
  table.insert(M.buffers, hex_buf.buf_hex, hex_buf)
end

return M
