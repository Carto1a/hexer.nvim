---@class Hexer
local M = { }

---@param path string
---@return HexerParsedLine[]
local function parser(path)
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

---@param buf integer
---@param parser_func fun(path: string): string[]
---@return HexerParsedLine[]
function M.dump(buf, parser_func)
  buf = buf or 0

  local file_path
  vim.api.nvim_buf_call(buf, function()
    file_path = vim.fn.expand("%:p")
  end)

  if parser_func ~= nil then
    return parser_func(file_path)
  end

  return parser(file_path)
end

---@param hex_buf HexerBuffer
function M.add_buffer(hex_buf)
  table.insert(M.buffers, hex_buf.buf_hex, hex_buf)
end

return M
