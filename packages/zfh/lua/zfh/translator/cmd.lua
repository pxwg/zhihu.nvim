---use pandoc/typst to convert HTML
---@module zfh.translator.cmd
local CMDTranslator = require 'zfh.translator'.CMDTranslator
local uv = require 'vim.uv'
local devnull = "/dev/null"
if uv.os_uname().sysname == "Windows" then
  devnull = "null"
end
local M = {
  readers = {
    pandoc = CMDTranslator { cmd = "zfh -fhtml -t%s -" },
  },
  writers = {
    pandoc = CMDTranslator { cmd = "zfh -f%s -" },
    typst = CMDTranslator { cmd = "typst compile --features=html -f html - - 2> " .. devnull },
  },
}
return M
