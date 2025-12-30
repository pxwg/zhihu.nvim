package.path = package.path .. ';lua/?.lua'

local auth = require "zhvim.auth"

-- luacheck: ignore 113
---@diagnostic disable: undefined-global
describe("test", function()
    local cookies = auth.load_cookies()
    it("tests get cookies", function()
        assert.are.equal(#cookies > 0, true)
    end)
end)
