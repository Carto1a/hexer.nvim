local win = require("hexer.window")

---@class HexerWinAddress: HexerWin
---@field private __index any
local M = setmetatable({}, { __index = win })
M.__index = M

---@private
function M:__tostring()
  return "HexerWinAddress"
end

---@param buf HexerBufferAddress
---@return HexerWinAddress
function M:new(buf)
  ---@type HexerWinAddress
  local obj = setmetatable(win:new("left", buf, 10, 10, false, "addres", true), self)

  return obj
end

---@param cursor_pos integer[]
---@param session HexerSession
function M:move_cursor(cursor_pos, session)
  assert(session)

  local hex_cursor = session.win_hex:get_cursor()
  local text_cursor = session.win_text:get_cursor()

  if hex_cursor then
    session.win_hex:set_cursor(cursor_pos[1], hex_cursor[2])
    session.win_hex.buf:hl(cursor_pos[1], hex_cursor[2])
  end

  if text_cursor then
    session.win_text:set_cursor(cursor_pos[1], text_cursor[2])
    session.win_text.buf:hl(cursor_pos[1], cursor_pos[2])
  end
end

return M
