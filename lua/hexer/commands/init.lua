---@class HexerCommand
---@field command fun(args: string[])
---@field complete fun(arg_lead: string, cmd_line: string, cursor_pos: integer): string[]

---@class HexerCommands
---@field commands HexerCommand[]
local M = { commands = {} }

local MAIN_COMMAND_NAME = "Hexer"

---@param path string
---@return string[]
local function list_modules(path)
  ---@type string[]
  local modules = {}
  local dir = vim.uv.fs_scandir(path)
  if not dir then return modules end

  while true do
    local name, t = vim.uv.fs_scandir_next(dir)
    if not name then break end
    if t == "file" and name:match("%.lua$") then
      local module = name:gsub("%.lua$", "")
      table.insert(modules, module)
    end
  end
  return modules
end

---@param arg_lead string
---@param cmd_line string
---@param cursor_pos integer
---@return string[]
local function complete(arg_lead, cmd_line, cursor_pos)
  local past_cmds = {}
  for cmd in cmd_line:gmatch("%S+") do
    table.insert(past_cmds, cmd)
  end

  local past_cmd = past_cmds[#past_cmds]
  if past_cmd == MAIN_COMMAND_NAME then
    local file = debug.getinfo(1, "S").source:sub(2)
    local dir = vim.fn.fnamemodify(file, ":h")
    return list_modules(dir)
  end

  ---@type boolean, HexerCommand
  local ok, command = pcall(require, "hexer.commands." .. past_cmd)
  if not ok then
    return {}
  end

  return command.complete(arg_lead, cmd_line, cursor_pos)
end

function M.init()
  vim.api.nvim_create_user_command("Hexer", function(opts)
    if #opts.fargs == 0 then
      require("hexer.commands.toggle").command({})
      return
    end

    local command_name = opts.fargs[1]

    ---@type boolean, HexerCommand
    local ok, command = pcall(require, "hexer.commands." .. command_name)
    if not ok then
      vim.print("command not found: " .. command_name)
      return
    end

    command.command(opts.fargs)
  end, {
    nargs = "*",
    complete = complete
  })
end

return M
