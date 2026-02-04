local M = {}
local default_opts = {}

---@class ZhihuOpts
---@field filetypes table<string, ZhihuFiletypeConfig> Mapping of filetypes to their configurations

---@class ZhihuFiletypeConfig
---@field type '"markdown_to_html"' | '"direct_html"'
---@field Article? table Optional, required if not using defaults
---@field converter? fun(content: string): string Required for 'markdown_to_html' type
---@field direct_converter? fun(content: string): string Required for 'direct_html' type
---@field template_prefix? string Optional prefix to prepend to the article (e.g., disclaimer, signature)

---Setup zhihu.nvim with optional configuration.
---
---# Example
---```lua
---{
---   filetypes = {
---     ['filetype'] = {
---       type = 'markdown_to_html' | 'direct_html',
---       Article = Article class, -- optional, required if not using defaults
---       converter = function(content) -> string, -- required for 'markdown_to_html' type
---       direct_converter = function(content) -> html_string, -- required for 'direct_html' type
---     },
---     ... -- You can define multiple filetypes
---   }
--- }
--- ```
---@param opts ZhihuOpts?
function M.setup(opts)
  opts = opts or {}
  default_opts = opts
  require("zhihu.article").create_autocmds(nil, opts)
end

function M.get_opts()
  return default_opts
end

return M
