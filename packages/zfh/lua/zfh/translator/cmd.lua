---use pandoc/typst to convert HTML
local CMDTranslator = require 'zfh.translator'.CMDTranslator
local M = {
  readers = {
    pandoc = CMDTranslator { cmd = "zfh %s -f html -t %s" },
  },
  writers = {
    pandoc = CMDTranslator { cmd = "zfh %s -f %s" },
    typst = CMDTranslator { cmd = "typst compile --features=html -f html %s" },
  },
}
return M
