---@class HexerWin
---@field id integer
---@field rised boolean
---@field position win_position
---@field buf HexerBuffer
---@field min_width integer
---@field width? integer
---@field focusable boolean
---@field title string
---@field noautocmd boolean
---@field indetifier? string
local M = {}
M.__index = M

---@private
function M:__tostring()
  return "HexerWinAddress"
end

---@protected
---@param position win_position
---@param buf HexerBuffer
---@param min_width integer
---@param width? integer
---@param focusable boolean
---@param title string
---@param noautocmd boolean
---@return HexerWin
function M:new(position, buf, min_width, width, focusable, title, noautocmd)
  ---@type HexerWin
  local obj = setmetatable({}, self)

  obj.rised = false
  obj.position = position
  obj.buf = buf
  obj.min_width = min_width
  obj.width = width
  obj.focusable = focusable
  obj.title = title
  obj.noautocmd = noautocmd

  return obj
end

---@param enter? boolean
function M:rise(enter)
  enter = enter or false

  local namespace = require("hexer.core").namespace

  self.id = vim.api.nvim_open_win(self.buf.id, enter,
    {
      width = self.width,
      split = self.position,
      focusable = self.focusable or true,
      noautocmd = self.noautocmd or false
    })

  assert(self.id, "can't open window for buffer:", self.buf.id, tostring(self.buf))

  self.rised = true
  vim.api.nvim_win_set_var(self.id, "hexer_indetifier", self.indetifier)
  vim.api.nvim_win_set_hl_ns(self.id, namespace)
end

-- TODO: não terminaie
---@param force boolean
---@overload fun()
function M:close(force)
  force = force == nil and false or force

  if vim.api.nvim_win_is_valid(self.id) then
    vim.api.nvim_win_close(self.id, force)
    self.rised = false
    return
  end

  self.rised = false
end

return M
