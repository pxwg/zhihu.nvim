---use pandoc/typst to convert HTML
local Translator = require 'zfh.translator'.Translator
local reader = require 'zfh.translator.cmd'.readers.pandoc
local writer = require 'zfh.translator.cmd'.writers.pandoc
local generator = require "zfh.generator.markdown".generator
local md_to_html = require "markdown_to_html".md_to_html
local M = {
  reader = Translator {
    translators = {
      html = function(...)
        return ...
      end,
      markdown = md_to_html,
      _ = reader,
    }
  },
  writer = Translator {
    translators = {
      html = function(...)
        return ...
      end,
      markdown = generator,
      _ = writer,
    }
  },
}
return M
