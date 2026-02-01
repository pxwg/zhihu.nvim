---get article according to filetype
local fs = require 'vim.fs'
local Get = require 'zhihu.api.article.get'.API
local M = {
  url = Get.url .. '/edit',
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
function M.filename_to_id(filename)
  -- luacheck: ignore 111 113
  ---@diagnostic disable: undefined-global
  filename = filename or vim.api.nvim_buf_get_name(0)
  local basename = fs.basename(vim.api.nvim_buf_get_name(0))
  return basename:match "^[^.]+" or ""
end

---open article's URL.
---for example:
---nnoremap <localleader>lv :lua require'zhihu.article'.open()<CR>
---@param id integer?
function M.open(id)
  id = id or vim.b.article and vim.b.article.itemId
  local url
  if tonumber(id) then
    url = M.url:format(id)
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
  local id = M.filename_to_id()
  local article
  if tonumber(id) then
    article = Article:from_id(id)
  else
    article = Article()
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
    local error = article:update()
    if error then
      vim.notify(error, vim.log.levels.ERROR)
    end
  else
    -- article:publish()
  end

  article.root = nil
  vim.b.article = article
end

---create autocmds
---@param augroup_id integer?
function M.create_autocmds(augroup_id)
  augroup_id = augroup_id or vim.api.nvim_create_augroup("zhihu", {})
  vim.api.nvim_create_autocmd({ "BufReadCmd", "SessionLoadPost" }, {
    pattern = "zhihu://*",
    group = augroup_id,
    callback = M.read_cb
  })
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    pattern = "zhihu://*",
    group = augroup_id,
    callback = M.write_cb
  })
end

return M
