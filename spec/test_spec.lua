package.path = package.path .. ';lua/?.lua'

local auth = require "zhihu.auth"
local Article = require "zhihu.article.html".Article
local template_path = require "zhihu.article.html".template_path
local generator = require "zhihu.article.html.markdown".generator

-- luacheck: ignore 113
---@diagnostic disable: undefined-global
describe("test", function()
    local cookies = auth.load_cookies()
    it("tests get cookies", function()
        assert.are.equal(#cookies > 0, true)
    end)
    local article = Article.from_id('581677880')
    it("tests get article", function()
        assert.are.equal(article.title, "深度学习并行训练算法一锅炖: DDP, TP, PP, ZeRO")
    end)
end)

describe("test", function()
    local code = generator:generate(Article.root)
    local f = io.open(template_path)
    local markdown = ""
    if f then
        markdown = f:read "*a"
        f:close()
    end
    it("tests code generated from HTML by markdown generator is original input of md_to_html()", function()
        assert.are.equal(code, markdown)
    end)
end)
