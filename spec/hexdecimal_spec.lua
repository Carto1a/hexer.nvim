local hexdecimal = require("core.hexdecimal")

describe('Hexdecimal List Class', function()
  it('Gerando a lista de hex', function()
    ---@type HexerFormatOptions
    local format = {
      grouped_bytes_per_row = 8,
      group_of_bytes = 4,
      address_length = 6,
      encoding = "ascii",
      endianness = "big-endian"
    }

    local hex_dump = "636172746f6c61206e76696d2068657865722e6e76696d0a"

    local hex = hexdecimal:new(hex_dump, format)

    assert.is.equals(hex_dump, hex:list_to_string())
  end)
end)
