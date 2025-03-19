---@class HexerBuffer
---@field file_path string
---@field buf_address integer
---@field buf_hex integer
---@field buf_text integer
---@field address_type ("hex" | "binary")
---@field endianness ("big-endian" | "little-endian")
---@field encoding ("ascii" | "utf-8")
local M = {}

---@param buf integer
local function load_buf_settings(buf)
  vim.bo[buf].ft = "xdd"
  vim.bo[buf].bin = true
  vim.bo[buf].mod = false

  -- vim.api.nvim_buf_call(buf, function()
  --   vim.cmd([[set nospell]])
  -- end)
end

function M:load_buf_settings()
  load_buf_settings(self.buf_address)
  load_buf_settings(self.buf_hex)
  load_buf_settings(self.buf_text)

  vim.api.nvim_create_autocmd("WinClosed", {
    callback = function()
      -- vim.api.nvim_win_close()
    end
  })
end

---@param address_type ("hex" | "binary")
---@param endianness ("big-endian" | "little-endian")
---@param encoding ("ascii" | "utf-8")
---@return HexerBuffer
function M:new(file_path, address_type, endianness, encoding)
  assert(file_path, "missing file path")
  -- TODO: verificar se o path é valido

  local obj = {
    buf_address = vim.api.nvim_create_buf(false, false),
    buf_hex = vim.api.nvim_create_buf(true, false),
    buf_text = vim.api.nvim_create_buf(true, false),

    file_path = file_path,
    address_type = address_type or "hex",
    endianness = endianness or "big-endian",
    encoding = encoding or "ascii"
  }

  setmetatable(obj, self)
  self.__index = self

  return obj
end

return M
