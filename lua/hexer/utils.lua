local M = {}

function M.binary_to_hex(command)
  vim.bo.bin = true
  vim.b['hexer'] = true
  vim.b.bin_ft = vim.b.ft
  vim.b.ft = "xxd"
  vim.cmd([[%!]] .. command)
end

function M.hex_to_binary(command)

end

function M.unload_lsp_servers(buf)
  buf = buf or 0
  local attached_servers = vim.lsp.get_clients({ bufnr = buf })
  for _, attached_server in ipairs(attached_servers) do
    attached_server.stop()
  end
end

function M.load_lsp_servers(buf)
  -- TODO: '-'
end

function M.load_hexer_configs()
end

function M.unload_hexer_configs()
  
end

return M
