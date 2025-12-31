package.path = package.path .. ';lua/?.lua'

local auth = require "zhihu.auth"
local Article = require "zhihu.article.html".Article

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
