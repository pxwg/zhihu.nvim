---Code generators for article
local parse = require 'htmlparser'.parse
local htmlEntities = require 'htmlEntities'
local deepcopy = require 'vim.shared'.deepcopy
local fn = require 'vim.fn'
local M = {
  Generator = {
  },
  ChainedGenerator = {
  },
  SelectorGenerator = {
    selector = "*",
    template = "%s",
  },
}

---TODO: https://github.com/msva/lua-htmlparser/issues/38#issuecomment-3707155560
---@param node table
---@param c string
function M.settext(node, c)
  node.root._text = node.root._text:sub(1, node._openstart - 1) .. c .. node.root._text:sub(node._closeend + 1)
end

---@param generator table?
---@return table generator
function M.Generator:new(generator)
  generator = generator or {}
  setmetatable(generator, {
    __index = self
  })
  return generator
end

setmetatable(M.Generator, {
  __call = M.Generator.new
})

---translate HTML to other markup language
---@param html string
---@return string code
function M.Generator:translate(html)
  local node = parse(html)
  return self:generate(node)
end

---generate other markup language from HTML node
---@param node table
---@return string code
function M.Generator:generate(node)
  local new_node, code = self:emit(node)
  local text = htmlEntities.decode(new_node:gettext())
  text = text:gsub("\n\n\n+", "\n\n")
  return fn.trim(text .. "\n\n" .. code)
end

---emit HTML tag to other language's AST node purely
---@see emit_
---@param node table
---@return table node
---@return string? code
function M.Generator:emit(node)
  node = deepcopy(node)
  return node, self:emit_(node)
end

---emit HTML tag to other language's AST node
---@param node table HTML content to be converted
---@return string? code footnote code
function M.Generator:emit_(node)
end

---@param generator table?
---@return table generator
function M.ChainedGenerator:new(generator)
  generator = generator or {}
  generator = M.Generator(generator)
  setmetatable(generator, {
    __index = self
  })
  return generator
end

setmetatable(M.ChainedGenerator, {
  __index = M.Generator,
  __call = M.ChainedGenerator.new
})

---emit HTML tag to other language's AST node in clain
---@param node table HTML content to be converted
---@return string code
function M.ChainedGenerator:emit_(node)
  local text = ""
  for _, generator in ipairs(self) do
    text = text .. (generator:emit_(node) or "")
  end
  return text
end

---@param generator table?
---@return table generator
function M.SelectorGenerator:new(generator)
  generator = generator or {}
  generator = M.Generator(generator)
  setmetatable(generator, {
    __index = self
  })
  return generator
end

setmetatable(M.SelectorGenerator, {
  __index = M.Generator,
  __call = M.SelectorGenerator.new
})

---convert all selected HTML tags in batch
---@param node table HTML content to be converted
---@return string? code
function M.SelectorGenerator:emit_(node)
  local text = ""
  local tag = node:select(self.selector)[1]
  while tag do
    text = text .. (self:convert_(tag) or "")
    local new_node = parse(node:gettext())
    for k, v in pairs(new_node) do
      node[k] = v
    end
    tag = node:select(self.selector)[1]
  end
  return text
end

---convert a HTML tag to other language's AST node
---@param node table HTML content to be converted
---@return string? code
function M.SelectorGenerator:convert_(node)
  local c = self.template:format(fn.trim(node:getcontent()))
  M.settext(node, c)
end

return M
