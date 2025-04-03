local M = {}

---@param session HexerSession
function M.start_windows(session)
  local windows = vim.api.nvim_list_wins()
  session.win_hex:rise(true)

  for _, win in pairs(windows) do
    local buf = vim.api.nvim_win_get_buf(win)
    local is_mod = vim.api.nvim_get_option_value("modified", { buf = buf })
    assert(not is_mod, "can't close modify buffers:", buf)

    vim.api.nvim_win_close(win, false)
  end

  session.win_text:rise()
  session.win_address:rise()
  session.hidden = false

  session.win_hex:sync_scroll({ session.win_address, session.win_text })
end

return M
