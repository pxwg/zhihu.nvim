---ldoc config
-- luacheck: ignore 111
---@diagnostic disable: lowercase-global
project = "zhihu.nvim"
readme = "README.md"
format = "cmark"
dir = "_readthedocs/html"
file = {
    "lua",
    "packages/auth/lua",
    "packages/zfh/lua",
    exclude = { "lua/zhihu/_meta.lua" }
}
