--- upload a zhihu image
local requests = require "requests"
local md5 = require 'zhihu.api.image.post'.md5
local sha1 = require'sha1'
local M = {
  mime_types = {
    jpg = "image/jpeg",
    jpeg = "image/jpeg",
    png = "image/png",
    gif = "image/gif",
    bmp = "image/bmp",
    webp = "image/webp",
  },
  string_to_sign = [[PUT

%s
%s
x-oss-date:%s
x-oss-security-token:%s
x-oss-user-agent:%s
/zhihu-pics/v2-%s]],
  API = {
    url = "https://zhihu-pics-upload.zhimg.com/v2-%s",
    headers = {
      ["User-Agent"] = "aliyun-sdk-js/6.8.0 Firefox 137.0 on OS X 10.15",
      ["Accept-Encoding"] = "gzip, deflate, br, zstd",
      ["Content-Type"] = "application/octet-stream",
      ["Accept-Language"] = "zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2",
      ["x-oss-user-agent: "] = "aliyun-sdk-js/6.8.0 Firefox 137.0 on OS X 10.15",
      ["Authorization"] = "OSS %s:%s",
    }
  }
}

---infer MIME type from file extension
---@param file string
---@return string? mime
function M.infer_mime_type(file)
  local ext = file:match("[^.]+$"):lower()
  return M.mime_types[ext]
end

---@param api table?
---@return table api
function M.API:new(api)
  api = api or {}
  setmetatable(api, {
    __index = self
  })
  return api
end

setmetatable(M.API, {
  __call = M.API.new
})

---factory method.
---@param file string
---@param access_id string
---@param access_token string
---@param access_key string
---@return table
function M.API.from_file(file, access_id, access_token, access_key)
  local api = {}
  local f = io.open(file, "rb")
  if f then
    api.data = f:read "*a"
    f:close()
  end
  api = M.API(api)
  api.headers["Content-Type"] = M.infer_mime_type(file) or api.headers["Content-Type"]
  api.headers["x-oss-date"] = os.date("!%a, %d %b %Y %H:%M:%S GMT")
  api.headers["x-oss-security-token"] = access_token
  local string_to_sign = M.string_to_sign:format(api.headers["Content-Type"], api.headers["x-oss-date"],
    api.headers["x-oss-date"], access_token, api.headers["User-Agent"], md5(file))
  local signature = vim.base64.encode(sha1.hmac_binary(access_key, string_to_sign))
  api.headers["Authorization"] = api.headers["Authorization"]:format(access_id, signature)
  return api
end

---request
---@return table
function M.API:request()
  return requests.put(self)
end

return M
