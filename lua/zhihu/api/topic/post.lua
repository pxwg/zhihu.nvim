--- attach topics to a zhihu article
local requests = require "requests"
local json = require 'vim.json'
local null = require 'cjson'.null
local uuid = require 'uuid'
uuid.set_rng(uuid.rng.math_random())
local auth = require 'zhihu.auth'
local M = {
  API = {
    url = "https://zhuanlan.zhihu.com/api/articles/%s/topics",
    headers = {
      ["User-Agent"] =
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36",
      ["Content-Type"] = "application/json",
      ["Accept-Encoding"] = "gzip, deflate, br, zstd",
      ["Accept-Language"] = "zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2",
      ["x-requested-with"] = "fetch",
    }
  }
}

return M
