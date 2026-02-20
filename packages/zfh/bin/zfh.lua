#!/usr/bin/env -S pandoc --lua-filter
---output zhihu flavored HTML
local pandoc = require 'pandoc'
local M = {}

---add lang
---@param elem table
---@return table | table[]?
function M.CodeBlock(elem)
  return {
    pandoc.RawInline("html", ('<pre lang="%s">'):format(elem.classes[1])),
    elem,
    pandoc.RawInline("html", "</pre>"),
  }
end

---add data-caption
---@param elem table
---@return table | table[]?
function M.Image(elem)
  local alt
  if elem.caption[1] then
    alt = elem.caption[1].text
  end
  if elem.src:match "//www.zhihu.com/equation?tex=" then
    return pandoc.Math("InlineMath", alt)
  end
  elem.attr.attributes.caption = alt
  return elem
end

--remove <figcaption></figcaption>
---@param elem table
---@return table | table[]?
function M.Figure(elem)
  elem.caption = pandoc.Caption()
  return elem
end

--convert math to an image
---@param elem table
---@return table | table[]?
function M.Math(elem)
  -- luacheck: ignore 111 113
  ---@diagnostic disable: undefined-global
  local elems = {}
  if elem.mathtype == "DisplayMath" then
    table.insert(elems, pandoc.RawInline("html", '<p>'))
  end
  local _elem
  if (FORMAT and FORMAT:match "html") == nil then
    _elem = pandoc.Image(elem.text, "//www.zhihu.com/equation?tex=" .. elem.text)
  else
    _elem = pandoc.RawInline("html",
      ('<img src="//www.zhihu.com/equation?tex=%s" eeimg="1" alt="%s" />'):format(elem.text, elem.text))
  end
  table.insert(elems, _elem)
  if elem.mathtype == "DisplayMath" then
    table.insert(elems, pandoc.RawInline("html", '</p>'))
  end
  return elems
end

return M
