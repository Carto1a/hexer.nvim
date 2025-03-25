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

---@param buf? integer
---@param parser_func? fun(path: string): string[]
---@return HexerParsedLine[]
function M.dump(buf, parser_func)
  buf = buf or 0

  local file_path = vim.api.nvim_buf_call(buf, function()
    return vim.fn.expand("%:p")
  end)

  if parser_func ~= nil then
    return parser_func(file_path)
  end

  return parser_file(file_path)
end

return M
