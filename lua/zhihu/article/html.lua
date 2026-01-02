--- a class to get/post/patch zhihu article in HTML
local Get = require 'zhihu.api.article.get'.API
local Post = require 'zhihu.api.article.post'.API
local Patch = require 'zhihu.api.article.patch'.API
local parse = require 'htmlparser'.parse
local md_to_html = require("markdown_to_html").md_to_html
local fs = require 'vim.fs'
local json = require 'vim.json'
local M = {
  selector = ".RichText.ztext",
  attribute = "data-zop",
  url = Get.url .. '/edit',
  Article = {
    itemId = "",
    title = "Untitled",
  },
}
M.template_path = fs.joinpath(
  fs.dirname(debug.getinfo(1).source:match("@?(.*)")),
  "templates", ("%s.md"):format(M.Article.title)
)
local text = ""
local f = io.open(M.template_path)
if f then
  text = f:read "*a"
  f:close()
end
-- similar as https://github.com/niudai/VSCode-Zhihu
M.Article.root = parse(md_to_html(text))

---@param article table?
---@return table article
function M.Article:new(article)
  article = article or {}
  setmetatable(article, {
    __tostring = self.tostring,
    __index = self
  })
  local meta = getmetatable(article.root)
  meta.__tostring = article.root.gettext
  setmetatable(article.root, meta)
  return article
end

---Convert a table<string, string> to string
---@return string
function M.Article:tostring()
  return tostring(self.root)
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
  if resp.status_code == 200 then
    return M.Article.from_html(resp.text)
  end
  return M.Article { itemId = resp.status }
end

---factory method.
---@param html string?
---@return table
function M.Article.from_html(html)
  local html = html or ""
  local root = parse(html)
  local tag = root:select(("[%s]"):format(M.attribute))[1]
  local article = json.decode(tag and tag.attributes[M.attribute]:gsub("&quot;", '"') or "{}")
  article.root = root:select(M.selector)[1] or root
  return M.Article(article)
end

---update article
---@return string? error
function M.Article:update()
  if tonumber(self.itemId) == nil then
    local api = Post.from_html(self.title, tostring(self.root))
    local resp = api:request()
    self.itemId = resp.status_code == 200 and resp.json().id or resp.status
  end
  if tonumber(self.itemId) == nil then
    return self.itemId
  end
  local api = Patch.from_id(self.itemId, self.title, tostring(self.root))
  local resp = api:request()
  if resp.status_code == 200 then
    return
  end
  return resp.status
end

---call `vim.ui.open()`
---@return string?
function M.Article:get_url()
  if tonumber(self.itemId) then
    return M.url:format(self.itemId)
  end
end

return M
