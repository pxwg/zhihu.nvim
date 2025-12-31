--- a class to get/post/patch zhihu article in markdown
local Article = require "zhihu.article.html".Article
local md_to_html = require("markdown_to_html").md_to_html
local fs = require 'vim.fs'
local fn = require 'vim.fn'
local get_python_executable = require'zhihu.auth.pychrome'.get_python_executable
local M = {
  Article = {
  }
}

---Convert HTML content to Markdown using a Python script.
---@param html_content string HTML content to be converted
---@return string md_content Converted Markdown content or an error message
function M.convert_html_to_md(html_content)
  local plugin_root = fs.dirname(debug.getinfo(1).source:match("@?(.*)"))
  local python_script = fs.joinpath(plugin_root, "scripts", "html_md.py")
  local python_executable = get_python_executable()

  local temp_file = "/tmp/nvim_html_to_md_content.html"
  local file = io.open(temp_file, "w")
  if not file then
    vim.notify("Failed to open temporary file for writing.", vim.log.levels.ERROR)
    return ""
  end
  file:write(html_content)
  file:close()

  local output = fn.system({ python_executable, python_script, temp_file })

  os.remove(temp_file)

  if vim.v.shell_error ~= 0 then
    vim.notify("Python script failed with error code: " .. output, vim.log.levels.ERROR)
    return ""
  end

  return output
end

---@param article table?
---@return table article
function M.Article:new(article)
  article = article or {}
  article = Article(article)
  setmetatable(article, {
    __index = self
  })
  return article
end

---factory method.
---@param id string
---@return table
function M.Article.from_id(id)
  local article = Article.from_id(id)
  article.markdown = M.convert_html_to_md(article.content)
  return article
end

---factory method.
---@param title string
---@param content string
---@return table
function M.Article.from_content(title, content)
  local article = Article.from_content(title, md_to_html(content))
  article.markdown = content
  return article
end

setmetatable(M.Article, {
  __index = Article,
  __call = M.Article.new
})

return M
