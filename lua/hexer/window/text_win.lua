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
function M:hl(cursor_pos)

end

---@param cursor_pos integer[]
---@param session HexerSession
function M:move_cursor(cursor_pos, session)
  assert(session)
  self:hl(cursor_pos)

  local address_cursor = vim.api.nvim_win_get_cursor(session.win_address.id)
  local hex_cursor = vim.api.nvim_win_get_cursor(session.win_hex.id)

  vim.api.nvim_win_set_cursor(session.win_address.id, { cursor_pos[1], address_cursor[2] })
  vim.api.nvim_win_set_cursor(session.win_hex.id, { cursor_pos[1], hex_cursor[2] })

  session.win_hex.buf:hl(cursor_pos[1], cursor_pos[2])
end

return M
