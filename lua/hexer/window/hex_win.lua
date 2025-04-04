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

  local address_cursor = vim.api.nvim_win_get_cursor(session.win_address.id)
  local text_cursor = vim.api.nvim_win_get_cursor(session.win_text.id)

  vim.api.nvim_win_set_cursor(session.win_address.id, { cursor_pos[1], address_cursor[2] })
  vim.api.nvim_win_set_cursor(session.win_text.id, { cursor_pos[1], text_cursor[2] })

  session.win_text:hl(cursor_pos)
end

return M
