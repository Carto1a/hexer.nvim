---@class Decoder
---@field decode fun(line: string): string

---@class DecoderAscii: Decoder
local DA = {}

local ascii_readable_start = 33
local ascii_readable_end = 126

---@param line string
---@return string
function DA.decode(line)
  local line_no_spaces = line:gsub("%s+", "")
  local decode_line = line_no_spaces:gsub("%x%x", function(cc)
    local decimal_char = tonumber(cc, 16)
    if decimal_char < ascii_readable_start or decimal_char > ascii_readable_end then
      -- TODO: mudar a cor para deixar bonito
      return "."
    end
    return string.char(decimal_char)
  end)

  return decode_line
end

---@class DecoderUtf8: Decoder
local DU8 = {}

-- TODO: fazer direito

---@param line string
---@return string
function DU8.decode(line)
  assert(false, "not implemented")
end

---@type { [encoding]: Decoder }
local Decoders = {
  ["ascii"] = DA,
  ["utf-8"] = DU8
}

return Decoders
