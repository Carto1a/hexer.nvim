local M = {}

local utils = require("hexer.utils")
local hexer = require("hexer.core")

local hexer_buffer = require("hexer.buffer")
local hexer_buffer_hex = require("hexer.buffer.hex_buf")
local hexer_buffer_text = require("hexer.buffer.text_buf")
local hexer_buffer_address = require("hexer.buffer.address_buf")

local hexer_win = require("hexer.window")
local hexer_win_hex = require("hexer.window.hex_win")
local hexer_win_text = require("hexer.window.text_win")
local hexer_win_address = require("hexer.window.address_win")
local hexer_win_menager = require("hexer.window.manager")

M.cfg = {}

local augroup_hexer = vim.api.nvim_create_augroup('hexer', { clear = true })

---@param buf? integer
---@param unload? boolean
function M.start_hexer(buf, unload)
  buf = buf or 0
  unload = unload or false

  local buf_hex = hexer_buffer_hex:new("big-endian")
  local buf_text = hexer_buffer_text:new("big-endian", "ascii")
  local buf_address = hexer_buffer_address:new()

  local win_hex = hexer_win_hex:new(buf_hex)
  local win_text = hexer_win_text:new(buf_text)
  local win_address = hexer_win_address:new(buf_address)

  if buf == 0 then buf = vim.api.nvim_get_current_buf() end
  local buf_is_valid = vim.api.nvim_buf_is_valid(buf)
  assert(buf_is_valid, "not a valid buf")

  hexer_win_menager.start_windows(win_address, win_hex, win_text)

  local buf_parsed_data = hexer.dump(buf)
  -- hexer.add_buffer(hexed_buffers)
  --
  -- for index, parsed_data in ipairs(buf_parsed_data) do
  --   local index_0 = index - 1
  --   vim.api.nvim_buf_set_lines(hexed_buffers.buf_address, index_0, index_0, false, { parsed_data.address .. ": " })
  --   vim.api.nvim_buf_set_lines(hexed_buffers.buf_hex, index_0, index_0, false, { parsed_data.hex })
  --   vim.api.nvim_buf_set_lines(hexed_buffers.buf_text, index_0, index_0, false, { parsed_data.text })
  -- end
  --
  -- -- TODO: disable "lukas-reineke/indent-blankline.nvim" on text buffer
  -- -- NOTE: ft xxd not work
  -- hexed_buffers:load_buf_settings()
  --
  -- vim.api.nvim_buf_delete(current_buf_id, { force = true })
  -- vim.api.nvim_set_current_buf(hexed_buffers.buf_hex)
  --
  -- vim.api.nvim_open_win(
  --   hexed_buffers.buf_address,
  --   false,
  --   { width = 10, split = "left", style = "minimal", focusable = false, noautocmd = true })
  --
  -- vim.api.nvim_open_win(
  --   hexed_buffers.buf_text,
  --   false,
  --   { width = 16, split = "right", style = "minimal" })
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
      M.start_hexer()
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
