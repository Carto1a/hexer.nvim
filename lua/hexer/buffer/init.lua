---@class HexerBuffer
---@field id integer
local M = {}
M.__index = M

function M:__tostring()
  return "HexerBuffer"
end

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

  obj.id = vim.api.nvim_create_buf(listed, false)
  assert(obj.id, "can't create buf, too bad")
  vim.api.nvim_set_option_value("buftype", "", { buf = obj.id })
  -- vim.api.nvim_set_option_value("buftype", "acwrite", { buf = obj.id })

  return obj
end

return M
