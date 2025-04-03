---@class HexerFormatOptions
---@field grouped_bytes_per_row integer
---@field group_of_bytes integer
---@field address_length integer

---@class HexerConfig
---@field format HexerFormatOptions

---@class HexerModule
---@field cfg HexerConfig
local M = {}

local utils = require("hexer.utils")
local core = require("hexer.core")

local hexer_buffer_hex = require("hexer.buffer.hex_buf")
local hexer_buffer_text = require("hexer.buffer.text_buf")
local hexer_buffer_address = require("hexer.buffer.address_buf")

local hexer_win_hex = require("hexer.window.hex_win")
local hexer_win_text = require("hexer.window.text_win")
local hexer_win_address = require("hexer.window.address_win")
local hexer_win_menager = require("hexer.window.manager")

M.cfg = {
  format = {
    grouped_bytes_per_row = 8,
    group_of_bytes = 4,
    address_length = 6
  }
}

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

  core.dump_buf_to(buf, buf_hex, buf_address, buf_text, M.cfg.format)

  hexer_win_menager.start_windows(win_address, win_hex, win_text)

  win_hex:sync_scroll(win_address, win_text)

  -- -- TODO: disable "lukas-reineke/indent-blankline.nvim" on text buffer
  -- -- NOTE: ft xxd not work
  -- hexed_buffers:load_buf_settings()
  --
  -- vim.api.nvim_buf_delete(current_buf_id, { force = true })
  -- vim.api.nvim_set_current_buf(hexed_buffers.buf_hex)
end

---@param force boolean
function M.stop_hexer(force)
  
end

function M.suspend_hexer()
  
end

-- function M.assemble()
--   vim.bo.bin = false
--   vim.b['hexer'] = false
--   vim.bo.ft = vim.b.bin_ft
--   vim.bo.mod = false
--
--   -- TODO: voltar com a config de spell do buffer
--   -- TODO: voltar com as lsp
--
--   local undolevels = vim.o.undolevels
--   vim.o.undolevels = -1
--   vim.cmd([[exe "normal a \<BS>\<Esc>"]])
--   vim.o.undolevels = undolevels
--
--   vim.api.nvim_command("e!")
-- end

-- function M.save()
--
-- end

-- local function setup_autocmds()
--   local autocmd = vim.api.nvim_create_autocmd
--
--   autocmd({ "BufWriteCmd" }, {
--     group = augroup_hexer,
--     pattern = "*",
--     callback = function(event)
--       if not vim.b.hexer then
--         vim.cmd("write")
--         return
--       end
--
--       vim.api.nvim_command("silent w !xxd -r > " .. event.file)
--       vim.bo.mod = false
--     end
--   })
-- end

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
    -- stop = function()
    --   M.assemble()
    -- end,
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

  -- setup_autocmds();
end

return M
