---@class HexerCore
---@field sessions { [string]: HexerSession }
---@field namespace integer
local M = {}

function M.setup()
  M.sessions = {}
  M.namespace = vim.api.nvim_create_namespace("Hexer")

  require("hexer.highlights").setup(M.namespace)
end

---@param session HexerSession
function M.assign_session(session)
  M.sessions[session.win_hex.indetifier] = session
end

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
---@param session HexerSession
---@param format HexerFormatOptions
function M.dump_buf_to(buf, session, format)
  assert(session)
  local formater = require("hexer.formater")

  local buf_hex = session.win_hex.buf
  local buf_address = session.win_address.buf
  local buf_text = session.win_text.buf
  ---@cast buf_hex HexerBufferHex
  ---@cast buf_address HexerBufferAddress
  ---@cast buf_text HexerBufferText

  buf = buf or 0

  local dump = dump_from_buf(buf)

  local i = 0
  ---@type HexerFormatHexLineReturn
  local formated = { lines = {}, buffer = "" }
  local last_line = ""

  vim.api.nvim_set_option_value("modifiable", true, { buf = buf_hex.id })
  vim.api.nvim_set_option_value("modifiable", true, { buf = buf_address.id })
  vim.api.nvim_set_option_value("modifiable", true, { buf = buf_text.id })

  -- NOTE: fazer a parte de formatação como uma pipeline? querbra as linhas,
  -- separa, formata etc
  for line in dump:gmatch("[^\r\n]+") do
    formated = formater.format_hex_line(line, formated.buffer, false, format)
    last_line = formated.buffer
    local formated_lines_count = #formated.lines

    if #formated.lines < 1 then
      goto continue
    end

    buf_hex:write_hex_lines(formated.lines, i, i + formated_lines_count - 1)
    buf_address:write_address(i, i + formated_lines_count - 1, format)
    buf_text:write_text_lines(i, i + formated_lines_count - 1, formated.lines, format)

    ::continue::
    i = i + 1 + formated_lines_count - 1
  end

  formated = formater.format_hex_line(last_line, "", true, format)
  buf_hex:write_hex_lines(formated.lines, i, i)
  buf_address:write_address(i, i, format)
  buf_text:write_text_lines(i, i, formated.lines, format)

  buf_address:set_modify(false)
  buf_hex:set_modify(false)
  buf_text:set_modify(false)

  vim.api.nvim_set_option_value("modifiable", false, { buf = buf_hex.id })
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf_address.id })
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf_text.id })

  session.loaded = true
end

---@return HexerSession?
---@overload fun(ids: integer[]): HexerSession?
function M.get_current_session()
  local windows_id = vim.api.nvim_list_wins()

  for _, window_id in pairs(windows_id) do
    local sucess, indetifier = pcall(vim.api.nvim_win_get_var, window_id, "hexer_indetifier")
    if not sucess or not indetifier then goto continue end
    ---@cast indetifier string

    local session = M.sessions[indetifier]
    if session then
      return session
    end

    ::continue::
  end

  return nil
end

---@param hexer_indetifier string
---@overload fun()
function M.suspend_hexer(hexer_indetifier)
  ---@type HexerSession?
  local session = nil
  if not hexer_indetifier then
    session = M.get_current_session()
  else
    session = M.sessions[hexer_indetifier]
  end

  if not session then
    print("no hexer stated")
    return
  end

  local dummy_buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_open_win(dummy_buf, true, { split = "left" })

  session.win_address:close(true)
  session.win_text:close(true)
  session.win_hex:close(true)
end

---@param hexer_indetifier string
---@overload fun()
function M.close_hexer(hexer_indetifier)
  local session = nil
  if hexer_indetifier then
    session = M.get_current_session()
  else
    session = M.sessions[hexer_indetifier]
  end
end

return M
