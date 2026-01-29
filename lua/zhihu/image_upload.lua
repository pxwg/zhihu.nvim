---will be refactored to lua/zhihu/api/image
local md5 = require "md5"
local guess = require 'mimetypes'.guess
local requests = require "requests"
local M = {}

---TODO: Reads a file as binary and calculates its SHA256 hash.
---@param file_path string The absolute path to the file
---@return string? The SHA256 hash of the file content, or nil if an error occurs
function M.read_file_and_hash(file_path)
  local f = io.open(file_path, "rb")
  local data = ""
  if f then
    data = f:read "*a"
    f:close()
  end
  return md5.sumhexa(data)
end

---Calculate the HMAC-SHA1 signature and return it as a base64-encoded string.
---@param access_key_secret string The secret key used for signing
---@param string_to_sign string The string to be signed
---@return string The base64-encoded signature
local function calculate_signature(access_key_secret, string_to_sign)
  local escaped_string_to_sign = string_to_sign:gsub("'", "'\\''")
  local escaped_access_key_secret = access_key_secret:gsub("'", "'\\''")
  local command = string.format(
    "printf '%s' | openssl dgst -sha1 -hmac '%s' -binary",
    escaped_string_to_sign,
    escaped_access_key_secret
  )
  local handle = io.popen(command)
  local signature = handle:read("*a"):gsub("%s+", "") -- Remove trailing whitespace/newlines
  handle:close()
  return vim.base64.encode(signature)
end

---Upload an image to Zhihu and return the response
---@param image_path string Absolute path to the image
---@param upload_token upload_token Authentication token for Zhihu API
---@return boolean? response
function M.upload_image(image_path, upload_token)
  local mime_type = guess(image_path) or "application/octet-stream"
  if not mime_type then
    vim.notify("Failed to infer MIME type for file: " .. image_path, vim.log.levels.ERROR)
    return nil
  end
  local img_hash = M.read_file_and_hash(image_path)
  local utc_date = os.date("!%a, %d %b %Y %H:%M:%S GMT")
  local ua = "aliyun-sdk-js/6.8.0 Firefox 137.0 on OS X 10.15"

  local string_to_sign = string.format(
    "PUT\n\n%s\n%s\nx-oss-date:%s\nx-oss-security-token:%s\nx-oss-user-agent:%s\n/zhihu-pics/v2-%s",
    mime_type,
    utc_date,
    utc_date,
    upload_token.access_token,
    ua,
    img_hash
  )

  local signature = calculate_signature(upload_token.access_key, string_to_sign)
  if not signature then
    vim.notify("Failed to calculate signature.", vim.log.levels.ERROR)
    return nil
  end

  local headers = {
    "User-Agent: " .. ua,
    "Accept-Encoding: gzip, deflate, br, zstd",
    "Content-Type: " .. mime_type,
    "Accept-Language: zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2",
    "x-oss-date: " .. utc_date,
    "x-oss-user-agent: " .. ua,
    "x-oss-security-token: " .. upload_token.access_token,
    "Authorization: OSS " .. upload_token.access_id .. ":" .. signature,
  }

  local file = assert(io.open(image_path, "rb"))
  local binary_data = file:read("*all")
  file:close()

  -- Prepare headers for curl command
  local isok, response = pcall(requests.put, {
    url = ("https://zhihu-pics-upload.zhimg.com/v2-%s"):format(img_hash),
    headers = headers,
    data = binary_data,
  })
  if not isok then
    vim.notify("Failed to upload image: " .. image_path, vim.log.levels.ERROR)
    return
  end
  if response.status_code ~= 200 then
    vim.notify("Failed to upload image: " .. image_path, vim.log.levels.ERROR)
    return
  end

  return response.text
end

return M
