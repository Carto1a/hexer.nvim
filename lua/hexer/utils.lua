---@module 'hexer.utils'
local M = {}

function M.binary_to_hex(command)
  vim.bo.bin = true
  vim.b['hexer'] = true
  vim.b.bin_ft = vim.b.ft
  vim.b.ft = "xxd"
  vim.cmd([[%!]] .. command)
end

function M.unload_lsp_servers(buf)
  buf = buf or 0
  local attached_servers = vim.lsp.get_clients({ bufnr = buf })
  for _, attached_server in ipairs(attached_servers) do
    attached_server.stop()
  end
end

function M.generate_uuid()
  math.randomseed(os.time())
  local random = math.random
  local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  return string.gsub(template, '[xy]', function(c)
    local v = (c == 'x') and random(0, 15) or random(8, 11)
    return string.format('%x', v)
  end)
end

return M
