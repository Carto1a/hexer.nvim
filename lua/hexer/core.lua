---@class Hexer
local M = {}

---@param path string
---@return string
local function dump_from_file(path)
  assert(vim.uv.fs_stat(path))

  local cmd = { "xxd", "-p", path }
  local cmd_system = vim.system(cmd, { text = true })

  local result = cmd_system:wait()
  assert(result.code, "code:", result.code)
  assert(result.stdout, "no data in stdout, maybe buffer is empty")

  return result.stdout
end

---@param buf integer
---@return string
local function dump_from_buf(buf)
  assert(buf ~= nil)
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

  assert(result.code, "code:", result.code)
  assert(result.stdout, "no data in stdout, maybe buffer is empty")

  return result.stdout
end

---@param buf? integer
---@param buf_hex HexerBufferHex
---@param buf_address HexerBufferAddress
---@param buf_text HexerBufferText
---@param format HexerFormatOptions
function M.dump_buf_to(buf, buf_hex, buf_address, buf_text, format)
  local formater = require("hexer.formater")

  buf = buf or 0

  local dump = dump_from_buf(buf)

  local i = 0
  ---@type HexerFormatHexLineReturn
  local formated = { lines = {}, buffer = "" }
  local last_line = ""

  -- NOTE: fazer a parte de formatação como uma pipeline? querbra as linhas,
  -- separa, formata etc
  for line in dump:gmatch("[^\r\n]+") do
    formated = formater.format_hex_line(line, formated.buffer, false, format)
    last_line = formated.buffer
    local formated_lines_count = #formated.lines
    buf_hex:write_hex_lines(formated.lines, i, i + formated_lines_count - 1)
    buf_address:write_address(i, i + formated_lines_count - 1, format)
    buf_text:write_text_lines(i, i + formated_lines_count - 1, formated.lines, format)

    i = i + 1 + formated_lines_count - 1
  end

  formated = formater.format_hex_line(last_line, "", true, format)
  buf_hex:write_hex_lines(formated.lines, i, i)
  buf_address:write_address(i, i, format)
  buf_text:write_text_lines(i, i, formated.lines, format)

  buf_address:set_modify(false)
  buf_hex:set_modify(false)
  buf_text:set_modify(false)
end

return M
