local M = {}

---@param session HexerSession
function M.sync_scroll(session)
  assert(session)

  local windows = { session.win_hex, session.win_address, session.win_text }

  vim.api.nvim_create_autocmd({ "CursorMoved" }, {
    pattern = "*",
    callback = function()
      local current_win_id = vim.api.nvim_get_current_win()
      for _, win in pairs(windows) do
        if current_win_id ~= win.id then
          goto continue
        end

        print("movendo o cursor na janela do id:", win.id)
        local cursor_pos = vim.api.nvim_win_get_cursor(current_win_id)
        print("cursor", vim.inspect(cursor_pos))

        win:move_cursor(cursor_pos, session)

        ::continue::
      end
    end
  })
end

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

  M.sync_scroll(session.win_hex, session.win_address, session.win_text)
end

return M
