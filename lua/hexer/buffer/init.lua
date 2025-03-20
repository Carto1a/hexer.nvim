---@class HexerBuffer
---@field id integer
local M = {}

---@param buf integer
local function load_buf_settings(buf)
  vim.bo[buf].bin = true
  vim.bo[buf].mod = false

  -- vim.api.nvim_buf_call(buf, function()
  --   vim.cmd([[set nospell]])
  -- end)
end

---@param listed boolean
---@return HexerBuffer
function M:new(listed)
  listed = listed or true

  ---@type HexerBuffer
  local obj = setmetatable({}, self)

  obj.id = vim.api.nvim_create_buf(listed, true)

  return obj
end

return M
