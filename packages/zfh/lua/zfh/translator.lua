---Code generators for article
-- luacheck: ignore 111 113
---@diagnostic disable: undefined-global
local fs = require 'vim.fs'
local fn = require 'vim.fn'
local M = {
  Translator = {
    translators = {
      html = function(...)
        return ...
      end,
      _ = function(...)
        return ...
      end
    }
  },
  CMDTranslator = {
    cmd = "cat %s"
  },
}

---@param translator table
---@return table article
function M.Translator:new(translator)
  translator = translator or {}
  setmetatable(translator, {
    __index = self,
    __call = self.translate,
  })
  return translator
end

setmetatable(M.Translator, {
  __call = M.Translator.new
})

---translate languages
function M.Translator:translate(...)
  if not vim then
    return ...
  end
  local translator = self.translators[vim.o.filetype] or self.translators._
  return translator(...)
end

---@param translator table
---@return table article
function M.CMDTranslator:new(translator)
  translator = translator or {}
  translator = M.Translator(translator)
  setmetatable(translator, {
    __index = self,
    __call = self.translate,
  })
  return translator
end

setmetatable(M.CMDTranslator, {
  __call = M.CMDTranslator.new
})

---translate languages
---@param text string
---@return string
function M.CMDTranslator:translate(text)
  -- luacheck: ignore 111 113
  ---@diagnostic disable: undefined-global
  local temp = fs.joinpath(os.getenv "TEMP" or "/tmp", "zfh.txt")
  local f = io.open(temp, "w")
  if f == nil then
    return text
  end
  f:write(text)
  f:close()
  local cmd = self.cmd:format(temp, vim and vim.o.filetype or "markdown")
  local p = io.popen(cmd)
  if p == nil then
    return text
  end
  text = p:read "*a"
  p:close()
  os.remove(temp)
  text = fn.trim(text)
  return text
end

return M
