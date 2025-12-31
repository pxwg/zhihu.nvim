local md_to_html = require("markdown_to_html").md_to_html
local Post = require 'api.image.post'.API
local Put = require 'api.image.put'.API
local md5 = require 'api.image.post'.md5
local infer_mime_type = require 'api.image.put'.infer_mime_type
local util = require("zhvim.util")
local fn = require 'vim.fn'
local fs = require 'vim.fs'
local M = {}

---@class upload_token
---@field access_id string
---@field access_key string
---@field access_token string
---@field access_timestamp number

---@class upload_file
---@field image_id string
---@field object_key string
---@field state number

---@class upload_response
---@field upload_vendor string
---@field upload_token upload_token
---@field upload_file upload_file

---@class html_content
---@field title string
---@field content string

---@class md_content
---@field content string Markdown content to be converted to HTML
---@field title string Title of the Markdown content

---Get the image link from Zhihu API or upload it if it is not uploaded.
---@param image_path string Absolute path to the image
---@param upload_token upload_token Authentication token for Zhihu API
---@param image_status number File information for the image
---@return string? New image URL or nil if upload failed
function M.get_image_link(image_path, upload_token, image_status)
  local base_dir = fs.dirname(vim.api.nvim_buf_get_name(0))
  image_path = util.get_absolute_path(image_path, base_dir)

  local img_hash = md5(image_path)
  if not img_hash then
    vim.notify("Failed to read or hash the file: " .. image_path, vim.log.levels.ERROR)
    return nil
  end
  local mime_type = infer_mime_type(image_path) or Put.headers["Content-Type"]
  local url = "https://picx.zhimg.com/v2-" .. img_hash .. "." .. mime_type:match("image/(%w+)")
  if image_status == 1 then
    return url
  elseif image_status == 2 then
    local response = Put.from_file(image_path, upload_token.access_id, upload_token.access_token, upload_token
      .access_key)
    if response.status_code == 200 then
      vim.notify("Image uploaded successfully.", vim.log.levels.INFO)
      return url
    else
      vim.notify("Failed to upload image.", vim.log.levels.ERROR)
      return nil
    end
  else
    vim.notify(
      "Image upload status is unknown: " .. image_status .. ", returning the default url",
      vim.log.levels.ERROR
    )
    return url
  end
end

-- Traverse the syntax tree to find image nodes and collect changes
local function get_md_image_changes(root, bufnr)
  local changes = {}

  local function upload_image(uri)
    local file_path = fn.expand(uri)
    local base_dir = fn.dirname(vim.api.nvim_buf_get_name(0))
    file_path = util.get_absolute_path(file_path, base_dir)

    local file = io.read(file_path)
    if file == nil then
      vim.notify("File does not exist: " .. file_path, vim.log.levels.ERROR)
      return uri
    end
    file:close()
    local upload_result = Post.from_file(file_path).json()
    if not upload_result then
      return uri
    end
    local result = M.get_image_link(file_path, upload_result.upload_token, upload_result.upload_file.state)
    if not result then
      return uri
    end
    return result
  end

  local function process_node(node)
    if node:type() == "image" then
      local url_node = nil
      for child in node:iter_children() do
        if child:type() == "link_destination" then
          url_node = child
          break
        end
      end
      local url = url_node and vim.treesitter.get_node_text(url_node, bufnr) or nil
      if url then
        local new_url = upload_image(url)
        table.insert(changes, {
          node = url_node,
          new_text = new_url,
        })
      end
    end
    for child in node:iter_children() do
      process_node(child)
    end
  end

  process_node(root)
  return changes
end

---Upload local Markdown figure to Zhihu and replace the link with the uploaded image link.
---Create a scratch buffer to fit the condition that filetype is not markdown.
---@param md_content string Markdown content to be processed
---@param cookies string Authentication cookies for Zhihu API
---@return string Updated Markdown content with new image links
function M.update_md_images(md_content, cookies)
  local bufnr = vim.api.nvim_create_buf(false, true)
  -- Set filetype to markdown to enable Treesitter
  vim.bo[bufnr].filetype = "markdown"
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(md_content, "\n"))

  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "markdown_inline")
  if not ok or not parser then
    vim.api.nvim_buf_delete(bufnr, { force = true })
    vim.notify("Treesitter parser for markdown is not available", vim.log.levels.ERROR)
    return md_content
  end

  local tree = parser:parse()[1]
  local root = tree:root()

  local changes = get_md_image_changes(root, bufnr)

  for _, change in ipairs(changes) do
    local start_row, start_col, end_row, end_col = change.node:range()
    md_content = util.replace_text(md_content, start_row, start_col, end_row, end_col, change.new_text)
  end

  vim.api.nvim_buf_delete(bufnr, { force = true })
  return md_content
end

---TODO: better replace based on Treesitter node range

---Convert Markdown content to HTML satisfying zhihu structure
---@param md_content md_content Markdown content to be converted
---@return html_content html_content content or an error message
---@return string|nil error
function M.convert_md_to_html(md_content)
  local title = md_content.title or "Untitled"
  local content = md_to_html(md_content.content or "")
  local result = {
    title = title,
    content = content,
  }

  return {
    title = result.title or "",
    content = result.content or "",
  }, nil
end

return M
