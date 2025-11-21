local win = require("hexer.window")

---@class HexerWinHex: HexerWin
---@field private __index any
local M = setmetatable({}, { __index = win })
M.__index = M

---@private
function M:__tostring()
  return "HexerWinHex"
end

---@param buf HexerBufferHex
---@return HexerWinHex
function M:new(buf)
  ---@type HexerWinHex
  local obj = setmetatable(win:new("right", buf, 16, nil, true, "hexer", true), self)

  return obj
end

---@param cursor_pos integer[]
---@param session HexerSession
function M:move_cursor(cursor_pos, session)
  assert(session)
  self.buf:hl(cursor_pos[1], cursor_pos[2])

  local address_cursor = session.win_address:get_cursor()
  local text_cursor = session.win_text:get_cursor()

  if address_cursor then
    session.win_address:set_cursor(cursor_pos[1], address_cursor[2])
  end

  if text_cursor then
    session.win_text:set_cursor(cursor_pos[1], text_cursor[2])
    session.win_text.buf:hl(cursor_pos[1], cursor_pos[2])
  end
end

return M
