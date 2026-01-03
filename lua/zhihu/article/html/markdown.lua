---Convert HTML content to Markdown
local fn = require 'vim.fn'
local fs = require 'vim.fs'
local get_python_executable = require 'zhihu.auth.pychrome'.get_python_executable
local M = {
  generator = {}
}

---Convert HTML content from a file to Markdown with specific rules.
---@param root table HTML content to be converted
---@return string markdown Converted Markdown content or an error message
function M.generator:generate(root)
  local plugin_root = fs.dirname(debug.getinfo(1).source:match("@?(.*)"))
  local python_script = fs.joinpath(plugin_root, "scripts", "html_md.py")
  local python_executable = get_python_executable()

  local temp_file = "/tmp/nvim_html_to_md_content.html"
  local file = io.open(temp_file, "w")
  if not file then
    vim.notify("Failed to open temporary file for writing.", vim.log.levels.ERROR)
    return ""
  end
  file:write(root:gettext())
  file:close()

  local output = fn.system({ python_executable, python_script, temp_file })

  os.remove(temp_file)

  if vim.v.shell_error ~= 0 then
    vim.notify("Python script failed with error code: " .. output, vim.log.levels.ERROR)
    return ""
  end

  return output
end

return M
