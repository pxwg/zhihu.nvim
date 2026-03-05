---default reader/writer
---@module zfh
local Translator = require 'zfh.translator'.Translator
local html_to_pandoc = require 'zfh.translator.cmd'.readers.pandoc
local pandoc_to_html = require 'zfh.translator.cmd'.writers.pandoc
local typst_to_html = require 'zfh.translator.cmd'.writers.typst
local html_to_md = require "zfh.generator.markdown".generator
local md_to_html = require "markdown_to_html".md_to_html
local M = {
  reader = Translator {
    translators = {
      html = function(...)
        return ...
      end,
      markdown = html_to_md,
      _ = html_to_pandoc,
    }
  },
  writer = Translator {
    translators = {
      html = function(...)
        return ...
      end,
      markdown = md_to_html,
      typst = typst_to_html,
      _ = pandoc_to_html,
    }
  },
}
return M
