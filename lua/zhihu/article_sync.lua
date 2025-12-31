local requests = require "requests"
local auth = require 'zhihu.auth'
local M = {
  headers = {
    ["User-Agent"] =
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36",
    ["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    ["accept-language"] = "zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2",
    ["upgrade-insecure-requests"] = "1",
    ["sec-fetch-dest"] = "document",
    ["sec-fetch-mode"] = "navigate",
    ["sec-fetch-site"] = "none",
    ["sec-fetch-user"] = "?1",
    ["priority"] = "u=0, i",
  }
}

--- Helper function to execute a curl command with headers
---@param url string The Zhihu article URL
---@return string? html_content The HTML content of the article, or nil if an error occurs
---@return string? error Error message if the download fails
function M.download_zhihu_article(url, cookies)
  headers = M.headers
  headers["Cookie"] = cookies or auth.load_cookies()
  local isok, response = pcall(requests.get, {
    url = url,
    headers = headers,
  })

  if not isok then
    return nil, response
  end
  if response.status_code ~= 200 then
    return nil, response.status
  end

  return response.text, nil
end

---Function to get md5 hash of the current buffer content.
---@param content string Content of the current buffer
---@return string md5 hash of the content
function M.get_buffer_hash(content) end

---Function to compare the current buffer content with a given hash.

return M
