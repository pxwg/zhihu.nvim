local git_ref = '$git_ref'
local modrev = '$modrev'
local specrev = '$specrev'

local repo_url = '$repo_url'

rockspec_format = '3.0'
package = '$package'
if modrev:sub(1, 1) == '$' then
  modrev = "scm"
  specrev = "1"
  repo_url = "https://github.com/pxwg/zhihu.nvim"
  package = repo_url:match("/([^/]+)/?$")
end
version = modrev .. '-' .. specrev

description = {
  summary = '$summary',
  detailed = '',
  labels = { 'zhihu', 'tex', 'typst', 'neovim', },
  homepage = '$homepage',
  license = 'MIT',
}

build_dependencies = {}

dependencies = { "lua >= 5.1", "platformdirs", "lsqlite3", "lua-requests-temp", "htmlparser", "lua-cjson", "md5", "sha1",
  "base64", "html-entities", "mimetypes", "uuid" }

test_dependencies = {}

source = {
  url = repo_url .. '/archive/' .. git_ref .. '.zip',
  dir = '$repo_name-' .. '$archive_dir_suffix',
}

if modrev == 'scm' or modrev == 'dev' then
  source = {
    url = repo_url:gsub('https', 'git')
  }
end

build = {
  type = 'rust-mlua',
  modules = {
    "chrome_cookie",
    "markdown_to_html",
  },
  install = {
    lua = {
      ["zhihu.auth.scripts.firefox"] = "lua/zhihu/auth/scripts/firefox.sql",
      ["zhihu.auth.scripts.auth_chrome"] = "lua/zhihu/auth/scripts/auth_chrome.py",
      ["zhihu.auth.auth"] = "lua/zhihu/auth/auth.lua",
      ["zhihu.auth.cache"] = "lua/zhihu/auth/cache.lua",
      ["zhihu.auth.chrome"] = "lua/zhihu/auth/chrome.lua",
      ["zhihu.auth.firefox"] = "lua/zhihu/auth/firefox.lua",
      ["zhihu.auth.pychrome"] = "lua/zhihu/auth/pychrome.lua",
      ["zhihu.auth"] = "lua/zhihu/auth.lua",
      ["zhihu.api.article.get"] = "lua/zhihu/api/article/get.lua",
      ["zhihu.api.article.post"] = "lua/zhihu/api/article/post.lua",
      ["zhihu.api.article.patch"] = "lua/zhihu/api/article/patch.lua",
      ["zhihu.api.image.post"] = "lua/zhihu/api/image/post.lua",
      ["zhihu.api.image.put"] = "lua/zhihu/api/image/put.lua",
      ["zhihu.api.answer.post"] = "lua/zhihu/api/answer/post.lua",
      ["zhihu.api"] = "lua/zhihu/api.lua",
      ["zhihu.article.templates.Untitled"] = "lua/zhihu/article/templates/Untitled.md",
      ["zhihu.article.generator.generator"] = "lua/zhihu/article/generator/generator.lua",
      ["zhihu.article.generator.markdown"] = "lua/zhihu/article/generator/markdown.lua",
      ["zhihu.article.html"] = "lua/zhihu/article/html.lua",
      ["zhihu.article.markdown"] = "lua/zhihu/article/markdown.lua",
      ["zhihu.article"] = "lua/zhihu/article.lua",
      ["zhihu.image"] = "lua/zhihu/image.lua",
    }
  },
}

