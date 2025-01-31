local M = {}

M.cfg = {}

local augroup_hexer = vim.api.nvim_create_augroup('hexer', { clear = true })

function M.dump()
  vim.bo.bin = true
  vim.b['hexer'] = true
  vim.b.bin_ft = vim.bo.ft
  vim.bo.ft = "xxd"
  vim.cmd([[%!]] .. "xxd")

  local attached_servers = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
  for _, attached_server in ipairs(attached_servers) do
    attached_server.stop()
  end

  local undolevels = vim.o.undolevels
  vim.o.undolevels = -1
  vim.cmd([[exe "normal a \<BS>\<Esc>"]])
  vim.o.undolevels = undolevels

  vim.bo.mod = false

  -- TODO: pegar a config de spell depois
  vim.cmd([[set nospell]])
end

function M.assemble()
  vim.bo.bin = false
  vim.b['hexer'] = false
  vim.bo.ft = vim.b.bin_ft
  vim.bo.mod = false

  -- TODO: voltar com a config de spell do buffer
  -- TODO: voltar com as lsp

  local undolevels = vim.o.undolevels
  vim.o.undolevels = -1
  vim.cmd([[exe "normal a \<BS>\<Esc>"]])
  vim.o.undolevels = undolevels

  vim.api.nvim_command("e!")
end

function M.save()
  
end

local function setup_autocmds()
  local autocmd = vim.api.nvim_create_autocmd

  autocmd({ "BufWriteCmd" }, {
    group = augroup_hexer,
    pattern = "*",
    callback = function(event)
      if not vim.b.hexer then
        vim.cmd("write")
        return
      end

      vim.api.nvim_command("silent w !xxd -r > " .. event.file)
      vim.bo.mod = false
    end
  })
end

function M.setup(args)
  if not vim.fn.executable("xxd") then
    vim.notify(
      "xxd is not installed on this system, aborting!",
      vim.log.levels.WARN
    )

    return
  end

  local commands = {
    start = function ()
      M.dump()
    end,
    save = function()
      print("save")
    end,
    stop = function()
      M.assemble()
    end,
    search = function(cmd_args)
      print("search")
      print("args: " .. vim.inspect(cmd_args))
    end
  }

  M.cfg = vim.tbl_deep_extend("force", M.cfg, args or {})

  vim.api.nvim_create_user_command("Hexer", function(opts)
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

  setup_autocmds();

end

return M
