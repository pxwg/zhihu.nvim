package.path = package.path .. ';lua/?.lua'

local url_to_id = require "zhihu.article".url_to_id
local Article = require "zhihu.article".Article
local Image = require "zhihu.image".Image
local template_path = require "zhihu.article".template_path
local generator = require "zfh.generator.markdown".generator

-- luacheck: ignore 113
---@diagnostic disable: undefined-global
describe("test zhihu", function()
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
end)

describe("test filename to id", function()
    it("tests answer", function()
        local id, question_id = url_to_id("zhihu://www.zhihu.com/question/470216447/answer/2006440722123998810.md")
        assert.are.equal(id, "2006440722123998810")
        assert.are.equal(question_id, "470216447")
        id, question_id = url_to_id("zhihu://www.zhihu.com/question/470216447/answer/new.md")
        assert.are.equal(id, nil)
        assert.are.equal(question_id, "470216447")
    end)
    it("tests article", function()
        local id, question_id = url_to_id("zhihu://zhuanlan.zhihu.com/p/2004918133526373893.html")
        assert.are.equal(id, "2004918133526373893")
        assert.are.equal(question_id, nil)
        id, question_id = url_to_id("zhihu://new.md")
        assert.are.equal(id, nil)
        assert.are.equal(question_id, nil)
    end)
end)
