---Convert HTML content to Markdown
local htmlEntities = require 'htmlEntities'
local url = require'socket.url'
local fn = require 'vim.fn'

local settext = require 'zfh.generator'.settext
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
  b = SelectorGenerator {
    selector = "b",
    template = "**%s**",
  },
  tex = SelectorGenerator {
    selector = ".ztext-math",
    template = "$%s$",
  },
  span = SelectorGenerator {
    selector = "span",
  },
  a = SelectorGenerator {
    selector = "a",
    template = "[%s](%s)",
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
    template = "[^%s]",
  },
  figure = SelectorGenerator {
    selector = "figure",
    template = "\n\n![%s](%s)\n\n",
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
    template = "| %s |\n",
  },
  p = SelectorGenerator {
    selector = "p",
    template = "%s\n\n",
  },
  blockquote = SelectorGenerator {
    selector = "blockquote",
    template = "> %s\n",
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
  local result = url.parse(href)
  if result.host == "link.zhihu.com" then
    href = url.unescape((result.query or ""):match("target=([^;]+)") or "")
  end
  local c = self.template:format(fn.trim(node:getcontent()), href)
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

$$
%s
$$

]]
  end
  local c = template:format(latex)
  settext(node, c)
end

---convert a HTML tag to other language's AST node
---@param node table HTML content to be converted
---@return string? code
function M.code_block:convert_(node)
  local pre = node:select"pre"[1]
  if not pre then
    return
  end
  local code = pre:select"code"[1]
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
  local c = self.template:format(node.attributes["data-numero"] or "")
  settext(node, c)
  local text = ("%s: %s %s\n"):format(c, node.attributes["data-text"] or "", node.attributes["data-url"] or "")
  return htmlEntities.decode(text)
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
  local c = "\n\n"
  for i, tr in ipairs(node:select "tr") do
    local tds = {}
    for _, tr in ipairs(tr:select "tr") do
      table.insert(tds, tr:getcontent())
    end
    for _, td in ipairs(tr:select "td") do
      table.insert(tds, td:getcontent())
    end
    c = c .. self.template:format(table.concat(tds, " | "))
    if i == 1 then
      c = c .. self.template:format(table.concat(fn.strwidth(tds), " | "))
    end
  end
  c = c .. "\n"
  settext(node, c)
end

---convert a HTML tag to other language's AST node
---@param node table HTML content to be converted
---@return string? code
function M.blockquote:convert_(node)
  local c = "\n\n"
  for line in fn.trim(node:getcontent()):gmatch "[^\n\r]+" do
    c = c .. self.template:format(line)
  end
  c = c .. "\n"
  settext(node, c)
end

M.generator = ChainedGenerator {
  M.head,
  M.br,
  M.i,
  M.b,
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

return M
