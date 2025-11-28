---@class HexerFormatOptions
---@field grouped_bytes_per_row integer
---@field group_of_bytes integer
---@field address_length integer
---@field endianness endianness
---@field encoding encoding

---@class HexerConfig
---@field format HexerFormatOptions

---@class HexerModule
---@field cfg HexerConfig
local M = {}

M.cfg = {
  format = {
    grouped_bytes_per_row = 8,
    group_of_bytes = 4,
    address_length = 6,
    encoding = "ascii",
    endianness = "big-endian"
  }
}

local augroup_hexer = vim.api.nvim_create_augroup('hexer', { clear = true })

---@param buf? integer
---@param unload_buf boolean
---@overload fun(buf?: integer)
function M.start_hexer(buf, unload_buf)
  -- unload_buf = unload_buf == nil and true or unload_buf
  -- buf = buf or 0
  --
  -- if buf == 0 then buf = vim.api.nvim_get_current_buf() end
  -- local buf_is_valid = vim.api.nvim_buf_is_valid(buf)
  -- assert(buf_is_valid, "not a valid buffer")
  --
  -- local core = require("hexer.core")
  -- local session = require("hexer.session")
  -- local window_menager = require("hexer.window.manager")
  --
  -- local hex_session = session:new(M.cfg.format)
  -- core.assign_session(hex_session)
  -- core.dump_buf_to(buf, hex_session, M.cfg.format)
  --
  -- window_menager.start_windows(hex_session)
  --
  -- -- -- -- TODO: disable "lukas-reineke/indent-blankline.nvim" on text buffer
  -- -- -- -- NOTE: ft xxd not work
  -- -- -- hexed_buffers:load_buf_settings()
  -- -- --
  -- -- -- vim.api.nvim_buf_delete(current_buf_id, { force = true })
  -- -- -- vim.api.nvim_set_current_buf(hexed_buffers.buf_hex)
end

function M.suspend_hexer()
  -- local core = require("hexer.core")
  -- core.suspend_hexer()
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

  require("hexer.commands").init()

  -- require("hexer.core").setup()

  -- M.cfg = vim.tbl_deep_extend("force", M.cfg, args or {})
end

return M
