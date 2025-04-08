---@class HexerWin
---@field id? integer
---@field rised boolean
---@field position win_position
---@field buf HexerBuffer
---@field min_width integer
---@field width? integer
---@field focusable boolean
---@field title string
---@field noautocmd boolean
---@field indetifier? string
---@field close_action? fun()
local M = {}
M.__index = M

---@private
function M:__tostring()
  return "HexerWin"
end

---@private
function M:setup_pre_close_event()
  assert(self.id)
  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(self.id),
    callback = function(event)
      if event.match ~= tostring(self.id) then return end

      self.rised = false
      self.id = nil

      if self.close_action then
        self:close_action()
      end

      -- remove autocmd
      return true
    end
  })
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
  self:setup_pre_close_event()
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
    return
  end

  self.rised = false
end

---@param throw? boolean
---@return integer[]?
function M:get_cursor(throw)
  throw = throw == nil and false or throw
  ---@cast throw boolean

  if not self.rised then
    if throw then assert(self.rised, "can't set cursor for a closed windows") end
    return nil
  end

  assert(self.id, "internal error, windows id not set")

  return vim.api.nvim_win_get_cursor(self.id)
end

---@param throw? boolean
function M:set_cursor(col, row, throw)
  throw = throw == nil and false or throw
  ---@cast throw boolean

  if not self.rised then
    if throw then assert(self.rised, "can't set cursor for a closed windows") end
    return
  end

  assert(self.id, "internal error, windows id not set")

  vim.api.nvim_win_set_cursor(self.id, { col, row })
end

return M
