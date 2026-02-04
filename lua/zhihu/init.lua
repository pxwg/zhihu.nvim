local M = {}
local default_opts = {}

---@class ZhihuFiletypeConfig
---@field type '"markdown"' | '"html"' Middle conversion strategy
---@field Article? table Optional, required if not using defaults
---@field converter? fun(content: string): string Required for 'markdown' type
---@field direct_converter? fun(content: string): string Required for 'html' type
---@field title? fun(content: string): string Optional function to generate title from content

---@class ZhihuOpts
---@field filetypes? table<string, ZhihuFiletypeConfig> Optional filetype configurations

---Setup zhihu.nvim with optional configuration.
---
---# Example
---```lua
---{
---   filetypes = {
---     ['filetype'] = {
---       type = 'markdown' | 'html',
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
