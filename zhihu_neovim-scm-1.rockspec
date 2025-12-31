local git_ref = '$git_ref'
local modrev = '$modrev'
local specrev = '$specrev'

local repo_url = '$repo_url'

rockspec_format = '3.0'
package = '$package'
if modrev:sub(1, 1) == '$' then
  modrev = "scm"
  specrev = "1"
  repo_url = "https://github.com/pxwg/zhihu_neovim"
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

dependencies = { "lua >= 5.1", "platformdirs", "lsqlite3", "lua-requests-temp" }

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
      ["zhvim.auth.scripts.firefox"] = "lua/zhvim/auth/scripts/firefox.sql",
      ["zhvim.auth.scripts.auth_chrome"] = "lua/zhvim/auth/scripts/auth_chrome.py",
      ["zhvim.auth.auth"] = "lua/zhvim/auth/auth.lua",
      ["zhvim.auth.chrome"] = "lua/zhvim/auth/chrome.lua",
      ["zhvim.auth.firefox"] = "lua/zhvim/auth/firefox.lua",
      ["zhvim.auth.pychrome"] = "lua/zhvim/auth/pychrome.lua",
      ["zhvim.auth"] = "lua/zhvim/auth.lua",
      ["zhvim.api.article.get"] = "lua/zhvim/api/article/get.lua",
      ["zhvim.api.article.post"] = "lua/zhvim/api/article/post.lua",
      ["zhvim.api.article.patch"] = "lua/zhvim/api/article/patch.lua",
      ["zhvim.api.image.post"] = "lua/zhvim/api/image/post.lua",
      ["zhvim.api.image.put"] = "lua/zhvim/api/image/put.lua",
      ["zhvim.article.scripts.html_md"] = "lua/zhvim/article/scripts/html_md.py",
      ["zhvim.article.scripts.parse_html"] = "lua/zhvim/article/scripts/parse_html.py",
      ["zhvim.article.html"] = "lua/zhvim/article/html.lua",
      ["zhvim.article.markdown"] = "lua/zhvim/article/markdown.lua",
      ["zhvim.image"] = "lua/zhvim/image.lua",
      ["zhvim.article_sync"] = "lua/zhvim/article_sync.lua",
      ["zhvim.article_upload"] = "lua/zhvim/article_upload.lua",
      ["zhvim.buf_id"] = "lua/zhvim/buf_id.lua",
      ["zhvim.commands"] = "lua/zhvim/commands.lua",
      ["zhvim.config"] = "lua/zhvim/config.lua",
      ["zhvim.init"] = "lua/zhvim/init.lua",
      ["zhvim.md_html"] = "lua/zhvim/md_html.lua",
      ["zhvim.script"] = "lua/zhvim/script.lua",
      ["zhvim.util"] = "lua/zhvim/util.lua",
    }
  },
}
