---get article according to filetype
local fs = require 'vim.fs'
local Get = require 'zhihu.api.article.get'.API
local html_article = require 'zhihu.article.html'.Article
local markdown_article = require 'zhihu.article.markdown'.Article
local md_to_html = require("markdown_to_html").md_to_html

local M = {
  url = Get.url .. '/edit',
  Articles = {},
  _custom_articles = {}, -- custom article configs from opts
}

-- Initialize with default articles
M.Articles = {
  html = html_article,
  markdown = markdown_article,
}
-- default
M.Articles[0] = M.Articles.markdown

---Register custom article types from user configuration
---@param opts table? Configuration options with filetypes definition
function M.register_filetypes(opts)
  if not opts or not opts.filetypes then
    return
  end
  
  for filetype, config in pairs(opts.filetypes) do
    M._custom_articles[filetype] = config
    M.Articles[filetype] = M._create_article_wrapper(filetype, config)
  end
end

---Create an article wrapper based on converter type
---@param filetype string
---@param config table {type, Article, converter, direct_converter}
---@return table Article class wrapper
function M._create_article_wrapper(filetype, config)
  local ArticleBase = config.Article or html_article
  
  if config.type == "markdown_to_html" then
    return M._create_markdown_to_html_article(ArticleBase, config.converter)
  elseif config.type == "direct_html" then
    return M._create_direct_html_article(ArticleBase, config.direct_converter)
  else
    error(("Invalid converter type for filetype '%s': %s"):format(filetype, config.type))
  end
end

---Create article class for markdown_to_html conversion
---@param ArticleBase table base Article class
---@param converter function(content: string) -> string (markdown to html)
---@return table Article class
function M._create_markdown_to_html_article(ArticleBase, converter)
  if not converter then
    error("markdown_to_html converter requires a 'converter' function")
  end
  
  local CustomArticle = {
    __base = ArticleBase,
  }
  
  function CustomArticle:new(article)
    article = article or {}
    article = ArticleBase(article)
    setmetatable(article, {
      __tostring = self.tostring,
      __index = self
    })
    return article
  end
  
  function CustomArticle:tostring()
    -- For markdown_to_html, we use base HTML class's tostring
    return ArticleBase.tostring(self)
  end
  
  setmetatable(CustomArticle, {
    __index = ArticleBase,
    __call = CustomArticle.new
  })
  
  function CustomArticle:set_content(content)
    local md = converter(content)
    self:set_html(md_to_html(md))
  end
  
  return CustomArticle
end

---Create article class for direct html conversion
---@param ArticleBase table base Article class
---@param direct_converter function(content: string) -> string (direct to html)
---@return table Article class
function M._create_direct_html_article(ArticleBase, direct_converter)
  if not direct_converter then
    error("direct_html converter requires a 'direct_converter' function")
  end
  
  local CustomArticle = {
    __base = ArticleBase,
  }
  
  function CustomArticle:new(article)
    article = article or {}
    article = ArticleBase(article)
    setmetatable(article, {
      __tostring = self.tostring,
      __index = self
    })
    return article
  end
  
  function CustomArticle:tostring()
    return ArticleBase.tostring(self)
  end
  
  setmetatable(CustomArticle, {
    __index = ArticleBase,
    __call = CustomArticle.new
  })
  
  function CustomArticle:set_content(content)
    local html = direct_converter(content)
    self:set_html(html)
  end
  
  return CustomArticle
end

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
---@param opts table? Configuration options with custom filetypes
function M.create_autocmds(augroup_id, opts)
  augroup_id = augroup_id or vim.api.nvim_create_augroup("zhihu", {})
  
  -- Register custom article types from options
  if opts then
    M.register_filetypes(opts)
  end
  
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
