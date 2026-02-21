---get article according to filetype
-- luacheck: ignore 111 113
---@diagnostic disable: undefined-global
local Article = require 'zhihu.article'.Article
local M = {}

---open article's URL.
---for example:
---nnoremap <localleader>lv :lua require'zhihu.article'.open()<CR>
---@param id integer?
---@param question_id integer?
---@param edit boolean?
function M.open(id, question_id, edit)
  if not vim.bo.modifiable then
    edit = false
  end
  local article = { itemId = id, question_id = question_id }
  if article.itemId == nil and article.question_id == nil then
    article = vim.b.article
  end
  article = Article(article)
  local url
  if article.itemId or article.question_id then
    url = article:get_url(edit)
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

  local article = Article:from_url(vim.api.nvim_buf_get_name(0))
  local lines = article:get_lines()
  vim.api.nvim_buf_set_lines(0, 0, -1, true, lines)

  article.root = nil
  vim.b.article = article
  if article.authorName ~= (Article.authorName or article.authorName) then
    vim.o.modifiable = false
  end
end

---callback for BufWriteCmd
function M.write_cb()
  if vim.o.modifiable == false then
    return
  end
  local article = Article(vim.b.article)
  if vim.o.modified then
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
    article:set_lines(lines)
  end
  local error = article:write()
  if error then
    vim.notify(error, vim.log.levels.ERROR)
  else
    vim.o.modified = false
  end

  article.root = nil
  vim.b.article = article
end

return M
