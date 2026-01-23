---Code generators for article
local deepcopy = require 'vim.shared'.deepcopy
local fn = require 'vim.fn'
local M = {
  Generator = {
  },
  ChainedGenerator = {
  },
  SelectorGenerator = {
    selector = "*",
    template = "",
  },
}

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

---@param root table
---@return string code
function M.Generator:generate(root)
  local new_root, code = self:emit(root)
  return new_root:gettext() .. "\n" .. code
end

---emit HTML tag to other language's AST node purely
---@see emit_
---@param root table
---@return table root
---@return string? code
function M.Generator:emit(root)
  root = deepcopy(root)
  return root, self:emit_(root)
end

---emit HTML tag to other language's AST node
---@param root table HTML content to be converted
---@return string? code footnote code
function M.Generator:emit_(root)
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
---@param root table HTML content to be converted
---@return string code
function M.ChainedGenerator:emit_(root)
  local text = ""
  for _, generator in ipairs(self) do
    text = text .. (generator:emit_(root) or "")
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
---@param root table HTML content to be converted
---@return string? code
function M.SelectorGenerator:emit_(root)
  local text = ""
  for _, tag in ipairs(root:select(self.selector)) do
    text = text .. (self:convert_(tag) or "")
  end
  return text
end

---convert a HTML tag to other language's AST node
---TODO: https://github.com/msva/lua-htmlparser/issues/38#issuecomment-3707155560
---@param root table HTML content to be converted
---@return string? code
function M.SelectorGenerator:convert_(root)
  root:settext(self.template:format(fn.trim(root:getcontent())))
end

return M
