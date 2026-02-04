---
-- Example converter implementations for typst, input is typst format content
-- and output is markdown format content
-- Requirment: Pandoc
---
--- NOTE: Though Typst is natively supported html output, the math content by the official Typst toolchain would generate SVG images for math formulas, which is not suitable for zhihu articles.

local M = {}

---Convert Typst format to Markdown
---@param typst_content string The raw Typst content
---@return string markdown content
function M.typst_to_markdown(typst_content)
  local temp_typ_file = os.tmpname() .. ".typ"
  local temp_md_file = os.tmpname() .. ".md"
  local f = io.open(temp_typ_file, "w")
  if not f then
    error("Cannot create temp typst file")
  end
  f:write(typst_content)
  f:close()
  local cmd = string.format("pandoc '%s' -t markdown -o '%s' 2>/dev/null", temp_typ_file, temp_md_file)
  local exit_code = os.execute(cmd)
  local markdown = ""
  if exit_code == 0 then
    local out = io.open(temp_md_file, "r")
    if out then
      markdown = out:read("*a")
      out:close()
    end
  else
    markdown = "Error: Pandoc conversion failed"
  end
  os.remove(temp_typ_file)
  os.remove(temp_md_file)
  return markdown
end

return M
