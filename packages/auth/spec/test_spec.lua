package.path = package.path .. ';lua/?.lua'

local auth = require "auth"

-- luacheck: ignore 113
---@diagnostic disable: undefined-global
describe("test auth", function()
    it("tests get cookies", function()
        assert.are.equal(#auth.dumps_cookies() > 0, true)
    end)
end)
