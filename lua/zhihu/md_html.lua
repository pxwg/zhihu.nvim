local md_to_html = require("markdown_to_html").md_to_html
local Image = require 'zhihu.image'.Image
local util = require("zhihu.util")
local fn = require 'vim.fn'
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

-- Traverse the syntax tree to find image nodes and collect changes
local function get_md_image_changes(root, bufnr)
  local changes = {}

  local function upload_image(uri)
    local file_path = fn.expand(uri)
    local base_dir = fn.dirname(vim.api.nvim_buf_get_name(0))
    file_path = util.get_absolute_path(file_path, base_dir)

    local image = Image { file = file_path }
    if not image:update() then
      return uri
    end
    return image.url
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
