local M = {}

---@param namespace integer
function M.setup(namespace)
  --- @param hl_group string Highlight group name, e.g. 'ErrorMsg'
  --- @param opts vim.api.keyset.highlight Highlight definition map
  local set_hl = function(hl_group, opts)
    opts.default = true -- Prevents overriding existing definitions
    vim.api.nvim_set_hl(namespace, hl_group, opts)
  end

  local clear_hl = function(hl_group)
    vim.api.nvim_set_hl(namespace, hl_group, {})
  end

  set_hl("HexerBufferHexOctet", { link = "CurSearch" })
end

return M
