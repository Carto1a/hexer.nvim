local M = {}

local utils = require("hexer.utils")
local hexer = require("hexer.core")
local hexer_buffer = require("hexer.buffer")

M.cfg = {}

local augroup_hexer = vim.api.nvim_create_augroup('hexer', { clear = true })

function M.dump()
  -- TODO: dont dump mod buffer

  local current_buf_id = vim.api.nvim_get_current_buf()
  local file_path = vim.fn.expand("%:p")

  -- TODO: fazer isso depois
  -- utils.unload_lsp_servers()

  local buf_parsed_data = hexer.dump(current_buf_id)
  local hexed_buffers = hexer_buffer:new(file_path, "hex", "big-endian", "ascii")

  hexer.add_buffer(hexed_buffers)

  for index, parsed_data in ipairs(buf_parsed_data) do
    local index_0 = index - 1
    vim.api.nvim_buf_set_lines(hexed_buffers.buf_address, index_0, index_0, false, { parsed_data.address .. ": " })
    vim.api.nvim_buf_set_lines(hexed_buffers.buf_hex, index_0, index_0, false, { parsed_data.hex })
    vim.api.nvim_buf_set_lines(hexed_buffers.buf_text, index_0, index_0, false, { parsed_data.text })
  end

  -- TODO: disable "lukas-reineke/indent-blankline.nvim" on text buffer
  -- NOTE: ft xxd not work
  hexed_buffers:load_buf_settings()

  vim.api.nvim_buf_delete(current_buf_id, { force = true })
  vim.api.nvim_set_current_buf(hexed_buffers.buf_hex)

  vim.api.nvim_open_win(
    hexed_buffers.buf_address,
    false,
    { width = 10, split = "left", style = "minimal", focusable = false })

  vim.api.nvim_open_win(
    hexed_buffers.buf_text,
    false,
    { width = 10, split = "right", style = "minimal" })
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
    start = function()
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
    end,
    test = function(cmd_args)
      vim.api.nvim_open_win(0, false,
        { split = 'left', width = 20, style = "minimal" })
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
