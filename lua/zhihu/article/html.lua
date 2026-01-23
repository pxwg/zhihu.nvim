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
  error_selector = ".ErrorPage-text",
  attribute = "data-zop",
  Article = {
    itemId = "",
    title = "Untitled",
  },
}
M.template_path = fs.joinpath(
  fs.dirname(debug.getinfo(1).source:match("@?(.*)")),
  "templates", ("%s.md"):format(M.Article.title)
)
local _text = ""
local _f = io.open(M.template_path)
if _f then
  _text = _f:read "*a"
  _f:close()
end
-- similar as https://github.com/niudai/VSCode-Zhihu
M.Article.root = parse(md_to_html(_text))
local meta = getmetatable(M.Article.root)
meta.__tostring = M.Article.root.gettext
setmetatable(M.Article.root, meta)

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

---factory method. wrap `from_html`
---@param id string
---@return table
function M.Article.from_id(id)
  local api = Get.from_id(id)
  local resp = api:request()
  local text = resp.status_code == 200 and resp.text or resp.status
  local article = M.Article.from_html(text)
  if article.itemId == "" then
    article.itemId = id
  end
  return article
end

---factory method.
---@param html string?
---@return table
function M.Article.from_html(html)
  html = html or ""
  local root = parse(html)
  local tag = root:select(("[%s]"):format(M.attribute))[1]
  local article = json.decode(tag and tag.attributes[M.attribute]:gsub("&quot;", '"') or "{}")
  article.root = root:select(M.selector)[1] or root:select(M.error_selector)[1] or parse ""
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

---split article to lines
---@return string[]
function M.Article:get_lines()
  local lines = {}
  for line in tostring(self):gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end
  return lines
end

---set HTML content
---@param html string
function M.Article:set_html(html)
  local root = parse(html)
  self.root = root:select(M.selector)[1] or root
end

M.Article.set_content = M.Article.set_html

---set lines
---@param lines string[]
function M.Article:set_lines(lines)
  local text = table.concat(lines, "\n")
  self:set_content(text)
end

return M
