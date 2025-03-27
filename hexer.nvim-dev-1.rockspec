package = "hexer.nvim"
version = "dev-1"
source = {
   url = "git+ssh://git@github.com/Carto1a/hexer.nvim.git"
}
description = {
   homepage = "*** please enter a project homepage ***",
   license = "*** please specify a license ***"
}
build = {
   type = "builtin",
   modules = {
      hexer = "lua\\hexer.lua",
      ["hexer.buffer.address_buf"] = "lua\\hexer\\buffer\\address_buf.lua",
      ["hexer.buffer.hex_buf"] = "lua\\hexer\\buffer\\hex_buf.lua",
      ["hexer.buffer.init"] = "lua\\hexer\\buffer\\init.lua",
      ["hexer.buffer.text_buf"] = "lua\\hexer\\buffer\\text_buf.lua",
      ["hexer.buffer.types"] = "lua\\hexer\\buffer\\types.lua",
      ["hexer.core"] = "lua\\hexer\\core.lua",
      ["hexer.hexerparsed"] = "lua\\hexer\\hexerparsed.lua",
      ["hexer.utils"] = "lua\\hexer\\utils.lua",
      ["hexer.window.address_win"] = "lua\\hexer\\window\\address_win.lua",
      ["hexer.window.hex_win"] = "lua\\hexer\\window\\hex_win.lua",
      ["hexer.window.init"] = "lua\\hexer\\window\\init.lua",
      ["hexer.window.manager"] = "lua\\hexer\\window\\manager.lua",
      ["hexer.window.text_win"] = "lua\\hexer\\window\\text_win.lua",
      ["hexer.window.types"] = "lua\\hexer\\window\\types.lua"
   }
}
