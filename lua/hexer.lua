local M = {}

M.cfg = {}

function M.setup(args)
  local commands = {
    start = function()
      print("start")
    end,
    save = function()
      print("save")
    end,
    stop = function()
      print("stop")
    end,
    search = function(cmd_args)
      print("search")
      print("args: " .. vim.inspect(cmd_args))
    end
  }

  M.cfg = vim.tbl_deep_extend("force", M.cfg, args or {})

  vim.api.nvim_create_user_command("Hexer", function(opts)
    print(vim.inspect(opts))
    local command_args = opts.fargs
    local command = commands[command_args[1]]
    if command then
      command(vim.list_slice(command_args, 2));
    end
  end, {
    nargs = "+",
    complete = function()
      return { "start", "save", "stop", "search" }
    end
  })
end

return M
