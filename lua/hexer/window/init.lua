---@class HexerWin
---@field rised boolean
local M = {}

---@return HexerWin
function M:new()
  ---@type HexerWin
  local obj = setmetatable({}, self)

  return obj
end

return M
