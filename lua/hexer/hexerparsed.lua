---@class HexerParsed
---@field address (string[] | nil)
---@field hex (string[] | nil)
---@field text (string[] | nil)
local M = {}

---@class HexerParsedLine
---@field address (string | nil)
---@field hex (string | nil)
---@field text (string | nil)
HexerParsedLine = {}

function M:new()
  local object = {}
  setmetatable(object, self)
  self.__index = self

  return object
end

---@param line HexerParsedLine
function M:add_line(line)
  -- TODO: validar? 1-1

  table.insert(self.address, line.address)
  table.insert(self.hex, line.hex)
  table.insert(self.text, line.text)
end

return M
