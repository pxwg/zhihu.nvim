---Convert HTML content to Typst
---@module zfh.generator.typst
local htmlEntities = require 'htmlEntities'
local fn = require 'vim.fn'

local settext = require 'zfh.generator'.settext
local strip = require 'zfh.generator'.strip
local ChainedGenerator = require 'zfh.generator'.ChainedGenerator
local SelectorGenerator = require 'zfh.generator'.SelectorGenerator

local M = {
  head = SelectorGenerator {
    selector = "head",
    template = "",
  },
  br = SelectorGenerator {
    selector = "br",
    template = "\n",
  },
  i = SelectorGenerator {
    selector = "i",
    template = "*%s*",
  },
  em = SelectorGenerator {
    selector = "em",
    template = "*%s*",
  },
  b = SelectorGenerator {
    selector = "b",
    template = "_%s_",
  },
  strong = SelectorGenerator {
    selector = "strong",
    template = "_%s_",
  },
  tex = SelectorGenerator {
    selector = ".ztext-math",
    template = "#mi[%s]",
  },
  span = SelectorGenerator {
    selector = "span",
  },
  a = SelectorGenerator {
    selector = "a",
    template = "#link(%q)[%s]",
  },
  code_block = SelectorGenerator {
    selector = "div.highlight",
    template = [[

```%s
%s
```

]],
  },
  code = SelectorGenerator {
    selector = "code",
    template = "`%s`",
  },
  sup = SelectorGenerator {
    selector = "sup[data-numero]",
    template = "#footnote[%s %s]",
  },
  figure = SelectorGenerator {
    selector = "figure",
    template = [[

#image(%q)

]],
  },
  h = {},
  ol = SelectorGenerator {
    selector = "ol",
    template = "%d. %s\n",
  },
  ul = SelectorGenerator {
    selector = "ul",
    template = "- %s\n",
  },
  table = SelectorGenerator {
    selector = "table",
    template = [[

#table(columns: %d, %s)

]],
  },
  p = SelectorGenerator {
    selector = "p",
    template = "%s\n\n",
  },
  blockquote = SelectorGenerator {
    selector = "blockquote",
    template = [[

#quote(block: true)[%s]

]],
  },
  div = SelectorGenerator {
    selector = "div",
  },
  body = SelectorGenerator {
    selector = "body",
  },
  html = SelectorGenerator {
    selector = "html",
  },
}

for i = 1, 6 do
  M.h[i] = SelectorGenerator {
    selector = ("h%d"):format(i),
    template = "\n\n" .. string.rep("#", i) .. " %s\n\n",
  }
end

---convert a HTML tag to other language's AST node
---@param node table HTML content to be converted
---@return string? code
function M.a:convert_(node)
  local href = node.attributes.href or ""
  local c = self.template:format(strip(href), fn.trim(node:getcontent()))
  settext(node, c)
end

---convert a HTML tag to other language's AST node
---@param node table HTML content to be converted
---@return string? code
function M.tex:convert_(node)
  local template = self.template
  local latex = node.attributes["data-tex"] or ""
  if latex:sub(-2) == "\\\\" then
    latex = latex:sub(1, -2)
    template = [[

#mitex(`
%s
`)

]]
  end
  local c = template:format(latex)
  settext(node, c)
  return '#import "@preview/mitex:0.2.6": *'
end

---convert a HTML tag to other language's AST node
---@param node table HTML content to be converted
---@return string? code
function M.code_block:convert_(node)
  local pre = node:select "pre"[1]
  if not pre then
    return
  end
  local code = pre:select "code"[1]
  if not code then
    return
  end
  local c = self.template:format((code.classes[1] or ""):gsub("^language--", ""), fn.trim(code:getcontent()))
  settext(node, c)
end

---convert a HTML tag to other language's AST node
---@param node table HTML content to be converted
---@return string? code
function M.sup:convert_(node)
  local c = self.template:format(node.attributes["data-text"] or "", node.attributes["data-url"] or "")
  settext(node, c)
end

---convert a HTML tag to other language's AST node
---@param node table HTML content to be converted
---@return string? code
function M.figure:convert_(node)
  local img = node:select "img"[1] or { attributes = {} }
  local figcaption = node:select "figcaption"[1]
  local c = self.template:format(figcaption and figcaption:getcontent() or "", img.attributes.src or "")
  settext(node, c)
end

---convert a HTML tag to other language's AST node
---@param node table HTML content to be converted
---@return string? code
function M.ol:convert_(node)
  local c = "\n\n"
  for i, li in ipairs(node:select "li") do
    c = c .. self.template:format(i, li:getcontent())
  end
  c = c .. "\n"
  settext(node, c)
end

---convert a HTML tag to other language's AST node
---@param node table HTML content to be converted
---@return string? code
function M.ul:convert_(node)
  local c = "\n\n"
  for _, li in ipairs(node:select "li") do
    c = c .. self.template:format(li:getcontent())
  end
  c = c .. "\n"
  settext(node, c)
end

---convert a HTML tag to other language's AST node
---@param node table HTML content to be converted
---@return string? code
function M.table:convert_(node)
  local c = ""
  local tds = {}
  local tr = node:select "tr"[1]
  if tr then
    for _, th in ipairs(tr:select "th") do
      table.insert(tds, ("%q"):format(th:getcontent()))
    end
    for _, td in ipairs(tr:select "td") do
      table.insert(tds, ("%q"):format(td:getcontent()))
    end
  end
  local columns = #tds
  tds = {}
  for _, th in ipairs(node:select "th") do
    table.insert(tds, ("%q"):format(th:getcontent()))
  end
  for _, td in ipairs(node:select "td") do
    table.insert(tds, ("%q"):format(td:getcontent()))
  end
  c = c .. table.concat(tds, ", ")
  c = self.template:format(columns, c)
  settext(node, c)
end

---convert a HTML tag to other language's AST node
---@param node table HTML content to be converted
---@return string? code
function M.blockquote:convert_(node)
  settext(node, self.template:format(fn.trim(node:getcontent())))
end

M.generator = ChainedGenerator {
  M.head,
  M.br,
  M.i,
  M.em,
  M.b,
  M.strong,
  M.tex,
  M.span,
  M.a,
  M.code_block,
  M.code,
  M.sup,
  M.figure,
  M.h[1], M.h[2], M.h[3], M.h[4], M.h[5], M.h[6],
  M.ol,
  M.ul,
  M.table,
  M.p,
  M.blockquote,
  M.div,
  M.body,
  M.html
}

---generate other markup language from HTML node
---@param node table
---@return string code
function M.generator:generate(node)
  local new_node, code = self:emit(node)
  local text = htmlEntities.decode(new_node:gettext())
  text = text:gsub("\n\n\n+", "\n\n")
  return fn.trim(code .. "\n\n" .. text)
end

return M
