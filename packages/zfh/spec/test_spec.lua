package.path = package.path .. ';lua/?.lua'

local fs = require 'vim.fs'
local generator = require "zfh.markdown".generator
local dir = fs.dirname(debug.getinfo(1).source:match("@?(.*)"))

describe("test converting html to markdown", function()
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
