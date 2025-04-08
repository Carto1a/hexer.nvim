local win = require("hexer.window")

---@class HexerWinText: HexerWin
---@field private __index any
local M = setmetatable({}, { __index = win })
M.__index = M

---@private
function M:__tostring()
  return "HexerWinText"
end

---@param buf HexerBufferText
---@return HexerWinText
function M:new(buf)
  ---@type HexerWinText
  local obj = setmetatable(win:new("right", buf, 16, 16, true, "text", true), self)

  return obj
end

---@param cursor_pos integer[]
---@param session HexerSession
function M:move_cursor(cursor_pos, session)
  assert(session)
  self.buf:hl(cursor_pos[1], cursor_pos[2])

  local address_cursor = session.win_address:get_cursor()
  local hex_cursor = session.win_hex:get_cursor()

  if address_cursor then
    session.win_address:set_cursor(cursor_pos[1], address_cursor[2])
  end

  if hex_cursor then
    session.win_hex:set_cursor(cursor_pos[1], hex_cursor[2])
    session.win_hex.buf:hl(cursor_pos[1], cursor_pos[2])
  end
end

return M
