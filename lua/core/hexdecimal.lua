---@class HexerHexdecimal
---@field hexe_list string[]
local M = {}
M.__index = M

---@private
function M:__tostring()
  return "HexerHexdecimal"
end

---@param hexdecimal_dump string
---@param format HexerFormatOptions
---@return HexerHexdecimal
function M:new(hexdecimal_dump, format)
  local formatter = require("core.formatter")

  ---@type HexerHexdecimal
  local obj = setmetatable({ hexe_list = {} }, self)

  ---@type HexerFormatHexLineReturn
  local formatted = { lines = {}, buffer = "" }
  local last_line = ""

  local i = 0
  for line in hexdecimal_dump:gmatch("[^\r\n]+") do
    formatted = formatter.format_hex_line(line, formatted.buffer, false, format)
    last_line = formatted.buffer

    if #formatted.lines < 1 then
      goto continue
    end

    table.move(formatted.lines, 1, #formatted.lines, #obj.hexe_list + 1, obj.hexe_list)

    ::continue::
    i = i + 1 + #formatted.lines - 1
  end

  formatted = formatter.format_hex_line(last_line, "", true, format)
  obj.hexe_list = table.move(formatted.lines, 1, #formatted.lines, #obj.hexe_list + 1, obj.hexe_list)

  return obj
end

function M:list_to_string()
  local string_stack = {}
  for _, value in ipairs(self.hexe_list) do
    local spaceless_string = value:gsub("%s", "")
    table.insert(string_stack, spaceless_string)
  end

  return table.concat(string_stack, "")
end

return M
