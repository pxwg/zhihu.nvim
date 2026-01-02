--- a class to get/post/patch zhihu article in HTML
local Get = require 'zhihu.api.article.get'.API
local Post = require 'zhihu.api.article.post'.API
local Patch = require 'zhihu.api.article.patch'.API
local parse = require 'htmlparser'.parse
local M = {
  selectors = {
    title = "title[data-rh='true']",
    writer = ".AuthorInfo-name .UserLink-link",
    content = ".RichText.ztext",
  },
  Article = {
  }
}

---Parse HTML content to extract user, article, and title information using a Python script.
---Writing to a temporary file and executing a Python script to parse the HTML.
---@param html string HTML content to be parsed
---@return string?
---@return string?
---@return table?
function M.parse(html)
  local root = parse(html)
  local elements = {}
  elements.title = root:select(M.selectors.title)[1] or {}
  elements.writer = root:select(M.selectors.writer)[1] or {}
  elements.content = root:select(M.selectors.content)[1] or {}
  local title = elements.title:getcontent()
  local writer = elements.writer:getcontent()
  title = title:match("(.*) -- 知乎$") or title
  return title, writer, elements.content
end

---@param article table?
---@return table article
function M.Article:new(article)
  article = article or {}
  setmetatable(article, {
    __tostring = self.tostring,
    __index = self
  })
  return article
end

---Convert a table<string, string> to string
---@return string
function M.Article:tostring()
  return self.content and self.content:gettext() or self.status
end

setmetatable(M.Article, {
  __call = M.Article.new
})

---factory method.
---@param id string
---@return table
function M.Article.from_id(id)
  local api = Get.from_id(id)
  local resp = api:request()
  local article = { id = id }
  if resp.status_code == 200 then
    article.title, article.writer, article.content = M.parse(resp.text)
  else
    article.status = resp.status
  end
  return M.Article(article)
end

---factory method.
---@param title string
---@param content string
---@return table
function M.Article.from_content(title, content)
  title = title or "未命名"
  content = content or ""
  local api = Post.from_html(title, content)
  local resp = api:request()
  local article = { title = title, content = parse(content) }
  if resp.status_code == 200 then
    article.id = resp.json().id
  else
    article.status = resp.status
  end
  return M.Article(article)
end

---update article
---@return boolean
function M.Article:update()
  local api = Patch.from_id(self.id, self.title, self.content)
  local resp = api:request()
  if resp.status_code ~= 200 then
    self.status = resp.status
    return false
  end
  return true
end

return M
