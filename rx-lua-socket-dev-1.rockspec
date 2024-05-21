rockspec_format = "3.0"
package = "rx-lua-socket"
version = "dev-1"
source = {
   url = "git+https://github.com/rodrigobello/rx-lua-socket.git"
}
dependencies = {
    "lua >= 5.1",
    "luasocket",
    "bjornbytes/rxlua"
}
description = {
   summary = "A LuaSocket driver for RxLua.",
   detailed = "A LuaSocket driver for RxLua.",
   homepage = "https://github.com/rodrigobello/rx-lua-socket",
   license = "*** please specify a license ***"
}
build = {
   type = "builtin",
   modules = {
      init = "init.lua"
   }
}
