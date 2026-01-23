--- init a zhihu image
local md5 = require "md5"
local requests = require "requests"
local json = require 'vim.json'
local auth = require 'zhihu.auth'
local M = {
  API = {
    url = "https://api.zhihu.com/images",
    headers = {
      ["Content-Type"] = "application/json",
      ["Accept-Language"] = "zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2",
    }
  }
}

---TODO: Reads a file as binary and calculates its SHA256 hash.
---@param file string The absolute path to the file
---@return string hash of the file content
function M.md5(file)
  local f = io.open(file)
  local text = ""
  if f then
    text = f:read"*a"
    f:close()
  end
  return md5.sumhexa(text)
end

---@param api table?
---@return table api
function M.API:new(api)
  api = api or {}
  setmetatable(api, {
    __index = self
  })
  api.headers.Cookie = auth.dumps_cookies()
  return api
end

setmetatable(M.API, {
  __call = M.API.new
})

---factory method.
---@param hash string
---@return table
function M.API.from_hash(hash)
  local body = {
    image_hash = hash,
    source = "article",
  }
  local api = {
    data = json.encode(body),
  }
  return M.API(api)
end

---factory method.
---@param file string
---@return table
function M.API.from_file(file)
  local hash = M.md5(file)
  return M.API.from_hash(hash)
end

---request
---@return table
function M.API:request()
  return requests.post(self)
end

return M
