--- a class to get/post/patch zhihu article in markdown
local Article = require "zhihu.article.html".Article
local md_to_html = require("markdown_to_html").md_to_html
local generator = require "zhihu.article.generator.markdown".generator
local M = {
  Article = {
  }
}

---@param article Article?
---@return Article article
function M.Article:new(article)
  article = article or {}
  article = Article(article)
  article.generator = article.generator or generator
  setmetatable(article, {
    __tostring = self.tostring,
    __index = self
  })
  return article
end

---Convert a table<string, string> to string
---@return string
function M.Article:tostring()
  return self.generator:generate(self.root)
end

setmetatable(M.Article, {
  __index = Article,
  __call = M.Article.new
})

---set content
---@param content string
function M.Article:set_content(content)
  self:set_html(md_to_html(content))
end

return M
