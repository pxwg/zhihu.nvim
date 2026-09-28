--- a class to get/post/patch zhihu image in HTML
local uv = require 'luv'
local socket = require "socket"
local Post = require 'zhihu.api.post.image'.API
local Put = require 'zhihu.api.put'.API
local Get = require 'zhihu.api.get'.API
local M = {
  Uploader = {
    status = "image %s %s",
  },
  Image = {
    src_type = "src",
    status = "%s after %d retries: ",
  }
}

---@param uploader table?
---@return Uploader uploader
function M.Uploader:new(uploader)
  uploader = uploader or {}
  setmetatable(uploader, {
    __tostring = self.tostring,
    __index = self
  })
  return uploader
end

setmetatable(M.Uploader, {
  __call = M.Uploader.new
})

---Convert a table<string, string> to string
---@return string
function M.Uploader:tostring()
  return (self.upload_file or {}).image_id or ""
end

---@param image table?
---@return Image image
function M.Image:new(image)
  image = image or {}
  setmetatable(image, {
    __tostring = self.tostring,
    __index = self
  })
  return image
end

setmetatable(M.Image, {
  __call = M.Image.new
})

---Convert a table<string, string> to string
---@return string
function M.Image:tostring()
  return self[self.src_type] or ""
end

---@param api table
---@param content string
---@param mimetype string
---@return Uploader uploader
function M.Uploader.from_api(api, content, mimetype)
  local resp = api:request()
  local uploader = M.Uploader(resp.json())
  if resp.status_code ~= 200 then
    return uploader
  end
  if uploader.upload_file.state ~= 1 and uploader.upload_file.state ~= 2 then
    uploader.status = "unknown state: " .. tostring(uploader.upload_file.state)
    return uploader
  end

  -- need to upload
  if uploader.upload_file.state == 2 then
    api = Put.from_image(content, mimetype, uploader)
    resp = api:request()
    if resp.status_code ~= 200 then
      uploader.status = resp.status
    else
      uploader.status = M.Uploader.status:format(tostring(uploader), "need uploading")
    end
  else
    uploader.status = M.Uploader.status:format(tostring(uploader), "already uploaded")
  end
  return uploader
end

---for test
---@param hash string
---@param content string
---@param mimetype string
---@return Uploader uploader
function M.Uploader.from_hash(hash, content, mimetype)
  local api = Post:from_hash(hash)
  return M.Uploader.from_api(api, content, mimetype)
end

---create from a file path
---@param file string
---@return Uploader uploader
function M.Uploader.from_file(file)
  local f, err = io.open(file, "rb")
  if not f then
    return M.Uploader { status = err }
  end
  local content = f:read "*a"
  f:close()

  local api = Post:from_content(content)
  local mimetype = require 'mimetypes'.guess(file)
  return M.Uploader.from_api(api, content, mimetype)
end

---fetch image synchronously
---@param id string
---@param max_retry integer?
---@param sleep_seconds integer?
---@return Image image
function M.fetch_image_sync(id, max_retry, sleep_seconds)
  max_retry = math.max(max_retry or 10, 1)
  sleep_seconds = sleep_seconds or 2
  local api = Get.from_id(id, nil, true)
  local image
  for i = 1, max_retry do
    local resp = api:request()
    image = M.Image(resp.json())
    if image.status == "success" then
      image.status = M.Image.status:format(image.status, i)
      return image
    end
    socket.sleep(sleep_seconds)
  end
  image.status = M.Image.status:format(image.status, max_retry) .. "time out"
  return image
end

---fetch image asynchronously
---This function uses uv_timer to check image status periodically without blocking the UI thread.
---@param id string The image ID to fetch
---@param max_retry integer? Maximum number of retry attempts (default: 10)
---@param sleep_seconds integer? Seconds to wait between retries (default: 1)
---@param callback function Callback function that receives the Image object when done
function M.fetch_image_async(id, max_retry, sleep_seconds, callback)
  max_retry = math.max(max_retry or 10, 1)
  sleep_seconds = sleep_seconds or 2
  local api = Get.from_id(id, nil, true)
  local timer = uv.new_timer()
  local attempt = 0

  local function on_check()
    attempt = attempt + 1
    local resp = api:request()
    local image = M.Image(resp.json())

    if image.status == "success" or attempt >= max_retry then
      timer:close()

      if image.status == "success" then
        image.status = M.Image.status:format(image.status, attempt)
      else
        image.status = M.Image.status:format(image.status, max_retry) .. "time out"
      end

      callback(image)
    end
  end

  timer:start(0, sleep_seconds * 1000, on_check)
end

return M
