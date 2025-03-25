local M = {}

---@param address_win HexerWin|HexerWinAddress
---@param hex_win HexerWin|HexerBufferHex
---@param text_win HexerWin|HexerBufferText
function M.start_windows(address_win, hex_win, text_win)

  local windows = vim.api.nvim_list_wins()
  hex_win:rise(true)

  for _, win in pairs(windows) do
    local buf = vim.api.nvim_win_get_buf(win)
    local is_mod = vim.api.nvim_get_option_value("mod", { buf = buf })
    assert(not is_mod, "can't close modify buffers:", buf)

    vim.api.nvim_win_close(win, false)
  end

  text_win:rise()
  address_win:rise()
end

return M
