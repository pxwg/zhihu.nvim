---get article according to filetype
local fs = require 'vim.fs'
local M = {
  Articles = {
    html = require 'zhihu.article.html'.Article,
    markdown = require 'zhihu.article.markdown'.Article,
  },
}
-- default
M.Articles[0] = M.Articles.markdown

---convert filename to id
---@param filename string?
---@return string id
---@return string? question_id
function M.filename_to_id(filename)
  -- luacheck: ignore 111 113
  ---@diagnostic disable: undefined-global
  filename = filename or vim.api.nvim_buf_get_name(0)
  local id = fs.basename(filename):match "^[^.]+" or ""
  local question_id = fs.dirname(filename):match "%d+"
  return id, question_id
end

---open article's URL.
---for example:
---nnoremap <localleader>lv :lua require'zhihu.article'.open()<CR>
---@param id integer?
---@param question_id integer?
---@param modifiable boolean?
function M.open(id, question_id, modifiable)
  id = id or vim.b.article.itemId
  question_id = question_id or vim.b.article.question_id
  if modifiable == nil then
    modifiable = vim.bo.modifiable
  end
  local url
  if tonumber(id) or tonumber(question_id) then
    local API = require'zhihu.api.get'.API
    local api = API.from_id(id, question_id)
    url = api.url
    if modifiable and tonumber(id) then
      url = url .. '/edit'
    end
  else
    url = vim.api.nvim_buf_get_name(0)
    if url:match "zhihu://" then
      vim.notify("run :w firstly!", vim.log.levels.WARN)
      return
    end
  end
  vim.ui.open(url)
end

---callback for BufReadCmd
function M.read_cb()
  vim.o.buftype = "acwrite"
  vim.cmd "filetype detect"

  local Article = M.Articles[vim.o.filetype] or M.Articles[0]
  local id, question_id = M.filename_to_id()
  local article
  if tonumber(id) then
    article = Article:from_id(id, question_id)
  else
    article = Article { question_id = question_id }
  end
  local lines = article:get_lines()
  vim.api.nvim_buf_set_lines(0, 0, -1, true, lines)

  article.root = nil
  vim.b.article = article
  if Article.authorName and article.authorName ~= Article.authorName then
    vim.o.modifiable = false
  end
end

---callback for BufWriteCmd
function M.write_cb()
  if vim.o.modifiable == false then
    return
  end
  local Article = M.Articles[vim.o.filetype] or M.Articles[0]
  local article = Article(vim.b.article)
  if vim.o.modified then
    vim.o.modified = false
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
    article:set_lines(lines)
    article.modified = true
  end
  local error = article:update()
  if error then
    vim.notify(error, vim.log.levels.ERROR)
  end

  article.root = nil
  vim.b.article = article
end

---callback for ExitPre
---TODO: publish
function M.exit_cb()
  local Article = M.Articles[vim.o.filetype] or M.Articles[0]
  local article = Article(vim.b.article)
  if article.modified then
    article:publish()
  end
end

return M
