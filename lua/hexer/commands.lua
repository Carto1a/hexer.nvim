---@class HexerCommands
---@field commands { [string]: fun(args: string[]) }
local M = {
  commands = {}
}

local function start(args)
  print("start")
end
M.commands["start"] = start

local function save(args)
  print("save")
end
M.commands["save"] = save

local function suspend(args)
  print("suspend")
end
M.commands["suspend"] = suspend

local function sessions(args)
  print("sessions")
end
M.commands["sessions"] = sessions

local function stop(args)
  print("stop")
end
M.commands["stop"] = stop

local function search(args)
  print("search")
end
M.commands["search"] = search

local function test(args)
  print("test")
end
M.commands["test"] = test

-- TODO: não terminei
M.commands = setmetatable(M.commands, {
  __index = function()
    local window = vim.api.nvim_get_current_win()
    ---@type string?
    local indetifier = vim.api.nvim_win_get_var(window, "hexer_indetifier")
    if not indetifier then
      return M.commands["start"]
    end

    return M.commands["suspend"]
  end
})

-- NOTE: vai ficar feio mesmo

---@param arg_lead string
---@param cmd_line string
---@param _ integer
---@return string[]
function M.complete(arg_lead, cmd_line, _)
  local past_cmds = {}
  for cmd in cmd_line:gmatch("%S+") do
    table.insert(past_cmds, cmd)
  end

  local past_cmd = past_cmds[#past_cmds]
  if past_cmd == "Hexer" then
    local commands = {}
    for key, _ in pairs(M.commands) do
      table.insert(commands, key)
    end

    return commands
  end

  if past_cmd == "save" then
    return vim.fn.getcompletion(arg_lead, "file")
  end

  return {}
end

return M
