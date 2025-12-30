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
version = modrev ..'-'.. specrev

description = {
  summary = '$summary',
  detailed = '',
  labels = { 'zhihu', 'tex', 'typst', 'neovim', },
  homepage = '$homepage',
  license = 'MIT',
}

build_dependencies = {  }

dependencies = { "lua >= 5.1", "lsqlite3", "plenary.nvim" }

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
  copy_directories = { 'util' },
  modules = {
    "chrome_cookie",
    "markdown_to_html",
  },
  install = {
    lua = {
      ["zhvim.article_sync"] = "lua/zhvim/article_sync.lua",
      ["zhvim.article_upload"] = "lua/zhvim/article_upload.lua",
      ["zhvim.buf_id"] = "lua/zhvim/buf_id.lua",
      ["zhvim.commands"] = "lua/zhvim/commands.lua",
      ["zhvim.config"] = "lua/zhvim/config.lua",
      ["zhvim.get_cookie"] = "lua/zhvim/get_cookie.lua",
      ["zhvim.html_md"] = "lua/zhvim/html_md.lua",
      ["zhvim.init"] = "lua/zhvim/init.lua",
      ["zhvim.md_html"] = "lua/zhvim/md_html.lua",
      ["zhvim.script"] = "lua/zhvim/script.lua",
      ["zhvim.util"] = "lua/zhvim/util.lua",
    }
  },
}
