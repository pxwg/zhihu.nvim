--- a class to get/post/patch zhihu article in HTML
local Get = require 'zhihu.api.article.get'.API
local Post = require 'zhihu.api.article.post'.API
local Patch = require 'zhihu.api.article.patch'.API
local json = require 'vim.json'
local fs = require 'vim.fs'
local fn = require 'vim.fn'
local get_python_executable = require'zhihu.auth.pychrome'.get_python_executable
local M = {
  Article = {
  }
}

---Parse HTML content to extract user, article, and title information using a Python script.
---Writing to a temporary file and executing a Python script to parse the HTML.
---@param html_content string HTML content to be parsed
---@return table parsed_data Parsed data containing title, content, and writer
function M.parse_zhihu_article(html_content)
  local plugin_root = fs.dirname(debug.getinfo(1).source:match("@?(.*)"))
  local python_script = fs.joinpath(plugin_root, "scripts", "parse_html.py")
  local python_executable = get_python_executable()

  local temp_file = "/tmp/nvim_zhihu_html_content.html"
  local file = io.open(temp_file, "w")
  if not file then
    vim.notify("Failed to open temporary file for writing.", vim.log.levels.ERROR)
    return {}
  end
  file:write(html_content)
  file:close()

  local output = fn.system({ python_executable, python_script, temp_file })

  os.remove(temp_file)

  if vim.v.shell_error ~= 0 then
    vim.notify("Python script failed with error code: " .. output, vim.log.levels.ERROR)
    return {}
  end

  local result = json.decode(output)
  if result.error then
    vim.notify("Error: " .. result.error, vim.log.levels.ERROR)
    return {}
  end

  return result
end

---@param article table?
---@return table article
function M.Article:new(article)
  article = article or {}
  setmetatable(article, {
    __index = self
  })
  return article
end

setmetatable(M.Article, {
  __call = M.Article.new
})

---factory method.
---@param id string
---@return table
function M.Article.from_id(id)
  local article = { id = id }
  local api = Get.from_id(id)
  local resp = api:request()
  if resp.status_code == 200 then
    local html_content = M.parse_zhihu_article(resp.text)
    article.content = html_content.content
    article.title = html_content.title:gsub(" -- 知乎$", "")
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
  local article = { title = title, content = content }
  local api = Post.from_html(title, content)
  local resp = api:request()
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
