local function toggle()
  local window = vim.api.nvim_get_current_win()
  ---@type string?
  local indetifier = vim.api.nvim_win_get_var(window, "hexer_indetifier")
  if not indetifier then
    return require("hexer.commands.dump").command({})
  end

  return M.commands["suspend"]
end

---@param args string[]
local function main(args)
  print(args)

  toggle()
end

local function complete()
  return {}
end

return {
  command = main,
  complete = complete
}
