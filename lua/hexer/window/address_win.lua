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

  local hexer_cursor = vim.api.nvim_win_get_cursor(session.win_hex.id)
  local text_cursor = vim.api.nvim_win_get_cursor(session.win_text.id)

  vim.api.nvim_win_set_cursor(session.win_hex.id, { cursor_pos[1], hexer_cursor[2] })
  vim.api.nvim_win_set_cursor(session.win_text.id, { cursor_pos[1], text_cursor[2] })

  session.win_hex.buf:hl(cursor_pos[1], hexer_cursor[2])
  session.win_text:hl(cursor_pos)
end

return M
