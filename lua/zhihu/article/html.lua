--- a class to get/post/patch zhihu article in HTML
local htmlEntities = require 'htmlEntities'
local fs = require 'vim.fs'
local split = require 'vim.shared'.split
local json = require 'vim.json'

local parse = require 'htmlparser'.parse
local md_to_html = require("markdown_to_html").md_to_html

local M = {
  selector = ".RichText.ztext",
  error_selector = ".ErrorPage-text",
  attribute = "data-zop",
  Article = {
    title = "Untitled",
    table_of_contents = false,
    delta_time = 30,
    can_reward = false,
    isTitleImageFullScreen = false,
    draft_type = "normal",
    disclaimer_type = "none",
    disclaimer_status = "closed",
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
local _meta = getmetatable(M.Article.root)
_meta.__tostring = M.Article.root.gettext
setmetatable(M.Article.root, _meta)

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
---@param question_id string?
---@return table
function M.Article:from_id(id, question_id)
  local Get = require 'zhihu.api.get'.API
  local api = Get.from_id(id, question_id)
  local resp = api:request()
  local text = resp.status_code == 200 and resp.text or resp.status
  local article = self:from_html(text)
  if article.itemId == nil then
    article.itemId = id
  else
    assert(article.itemId == id)
  end
  article.question_id = question_id
  return article
end

---factory method.
---@param html string?
---@return table
function M.Article:from_html(html)
  html = html or ""
  local root = parse(html)
  local tag = root:select(("[%s]"):format(M.attribute))[1]
  local article = json.decode(tag and htmlEntities.decode(tag.attributes[M.attribute]) or "{}")
  article.root = root:select(M.selector)[1] or root:select(M.error_selector)[1] or root
  if article.root.root ~= article.root then
    article.root = parse(article.root:gettext())
  end
  return self(article)
end

---write an article or answer
---@param publish boolean?
---@return string? error
function M.Article:write(publish)
  if publish == nil then
    publish = self.disclaimer_type and self.disclaimer_status and true
  end
  if publish then
    return self:publish()
  end
  return self:upload()
end

---publish an article or answer
---@return string? error
function M.Article:publish()
  local Post = require 'zhihu.api.post.publish'.API
  local api = Post:from_article(self)
  local resp = api:request()
  if resp.status_code ~= 200 then
    return resp.status
  end
  local output = resp.json()
  if output.code ~= 0 then
    return output.message
  end
  local publish = json.decode(output.data.result).publish
  self.itemId = publish.id
  self.authorName = publish.author.name
  assert(self.question_id == publish.question.id)
end

---upload an article or answer to draft box
---@return string? error
function M.Article:upload()
  -- nothing need to be updated
  if self.root == nil and self.titleImage == nil then
    return
  end
  if self.question_id == nil and self.itemId == nil then
    local Post = require 'zhihu.api.post.article'.API
    local api = Post:from_article(self)
    local resp = api:request()
    if resp.status_code ~= 200 then
      return resp.status
    end
    self.itemId = resp.json().id
  end
  local API
  if self.question_id then
    API = require 'zhihu.api.post.answer'.API
  else
    API = require 'zhihu.api.patch'.API
  end
  local api = API:from_article(self)
  local resp = api:request()
  if resp.status_code ~= 200 then
    return resp.status
  end
end

---split article to lines
---@return string[]
function M.Article:get_lines()
  local text = tostring(self)
  return split(text, "\n\r?")
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

---get URL
---@param edit boolean?
---@return string url
function M.Article:get_url(edit)
  if edit == nil then
    local publish = self.disclaimer_type and self.disclaimer_status and true
    edit = not publish
  end
  local API = require 'zhihu.api.get'.API
  local api = API.from_id(self.itemId, self.question_id)
  local url = api.url
  if edit and self.itemId then
    url = url .. '/edit'
  end
  return url
end

return M
