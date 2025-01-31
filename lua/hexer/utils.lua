local M = {}

function binary_to_hex(command)
  vim.bo.bin = true
  vim.b['hexer'] = true
  vim.b.bin_ft = vim.b.ft
  vim.b.ft = "xxd"
  vim.cmd([[%!]] .. command)
end

function hex_to_binary(command)

end

return M
