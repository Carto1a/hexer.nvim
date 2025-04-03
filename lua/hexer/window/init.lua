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
  vim.api.nvim_win_set_var(self.id, "hexer_indetifier", self.indetifier)
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

---@param windows HexerWin[]
function M:sync_scroll(windows)
  ---@param win HexerWin
  local create_autocmd = function(win)
    vim.api.nvim_create_autocmd({ "CursorMoved" }, {
      pattern = "*",
      callback = function()
        local current_win_id = vim.api.nvim_get_current_win()
        if current_win_id == win.id then
          print("movendo o cursor na janela do id:", win.id)
        end
      end
    })
  end

  create_autocmd(self)
  for _, win in pairs(windows) do
    create_autocmd(win)
  end

  -- vim.api.nvim_create_autocmd({ "CursorMoved" }, {
  --   pattern = "*",
  --   callback = function()
  --     local find_window = function()
  --       local current_win_id = vim.api.nvim_get_current_win()
  --       for _, win in pairs(windows) do
  --         if win.id == current_win_id then
  --           return win
  --         end
  --       end
  --     end
  --
  --     local win = find_window()
  --     local cursor_index = vim.api.nvim_win_get_cursor(win.id)
  --
  --
  --
  --     print(vim.inspect(cursor_index))
  --   end
  -- })
end

return M
