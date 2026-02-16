package.path = package.path .. ';lua/?.lua'

local fs = require 'vim.fs'

local auth = require "zhihu.auth"
local filename_to_id = require "zhihu.article".filename_to_id
local Article = require "zhihu.article.html".Article
local Image = require "zhihu.image".Image
local template_path = require "zhihu.article.html".template_path
local generator = require "zhihu.article.generator.markdown".generator

local dir = fs.dirname(debug.getinfo(1).source:match("@?(.*)"))

-- luacheck: ignore 113
---@diagnostic disable: undefined-global
describe("test zhihu", function()
    it("tests get cookies", function()
        assert.are.equal(#auth.dumps_cookies() > 0, true)
    end)
    local article = Article:from_id "581677880"
    it("tests get article", function()
        assert.are.equal(article.title, "深度学习并行训练算法一锅炖: DDP, TP, PP, ZeRO")
    end)
    local image = Image.from_hash "36828cdbb31942c394c5d2ea92aef201"
    it("tests get image", function()
        assert.are.equal(image.upload_file.state, 1)
    end)
end)

describe("test converting html to markdown", function()
    local code = generator:generate(Article.root)
    local f = io.open(template_path)
    local markdown = ""
    if f then
        markdown = f:read "*a":sub(1, -2)
        f:close()
    end
    it("tests code generated from HTML by markdown generator is original input of md_to_html()", function()
        assert.are.equal(code, markdown)
    end)

    local html = ""
    local path = fs.joinpath(dir, "404.html")
    f = io.open(path)
    if f then
        html = f:read "*a"
        f:close()
    end
    path = fs.joinpath(dir, "404.md")
    f = io.open(path)
    markdown = ""
    if f then
        markdown = f:read "*a":sub(1, -2)
        f:close()
    end
    code = generator:translate(html)
    it("tests 404", function()
        assert.are.equal(code, markdown)
    end)
end)

describe("test filename to id", function()
    it("tests answer", function()
        local id, question_id = filename_to_id("zhihu://www.zhihu.com/question/470216447/answer/2006440722123998810.md")
        assert.are.equal(id, "2006440722123998810")
        assert.are.equal(question_id, "470216447")
        id, question_id = filename_to_id("zhihu://www.zhihu.com/question/470216447/answer/new.md")
        assert.are.equal(id, "new")
        assert.are.equal(question_id, "470216447")
    end)
    it("tests article", function()
        local id, question_id = filename_to_id("zhihu://zhuanlan.zhihu.com/p/2004918133526373893.html")
        assert.are.equal(id, "2004918133526373893")
        assert.are.equal(question_id, nil)
        id, question_id = filename_to_id("zhihu://new.md")
        assert.are.equal(id, "new")
        assert.are.equal(question_id, nil)
    end)
end)
