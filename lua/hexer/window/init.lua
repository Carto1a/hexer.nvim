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
local M = {}
M.__index = M

function M:__tostring()
  return "HexerWinAddress"
end

---@return HexerWin
---@param position win_position
---@param buf HexerBuffer
---@param min_width integer
---@param width? integer
---@param focusable boolean
---@param title string
---@param noautocmd boolean
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

  self.id = vim.api.nvim_open_win(self.buf.id, enter,
    {
      width = self.width,
      split = self.position,
      focusable = self.focusable or true,
      noautocmd = self.noautocmd or false
    })

  assert(self.id, "can't open window for buffer:", self.buf.id, tostring(self.buf))

  self.rised = true
end

---@param force boolean?
function M:close(force)
  force = force or false
  vim.api.nvim_win_close(self.id, force)
  self.rised = false
end

---@param ... HexerWin
function M:sync_scroll(...)
  -- vim.api.nvim_create_autocmd({ "CursorMoved" }, {
  --   pattern = "*",
  --   callback = function()
  --     local cursor_index = vim.api.nvim_win_get_cursor(self.id)
  --     print(vim.inspect(cursor_index))
  --   end
  -- })
end

return M
