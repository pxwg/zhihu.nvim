package.path = package.path .. ';lua/?.lua'

local auth = require 'auth.cache'.Auth()

-- luacheck: ignore 113
---@diagnostic disable: undefined-global
describe("test auth", function()
    it("tests get cookies", function()
        assert.are.equal(#tostring(auth:get_cookies ".zhihu.com") > 0, true)
    end)
end)
