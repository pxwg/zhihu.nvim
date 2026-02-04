---
-- Example: How to setup zhihu.nvim with custom filetypes
-- 
-- This file demonstrates two patterns for adding custom file converters:
-- 1. markdown_to_html: Convert to markdown first, then to HTML
-- 2. direct_html: Convert directly to HTML
---

-- Assume you have installed zhihu.nvim with lazy.nvim or rocks.nvim

-- Example: Typst -> Markdown -> HTML
require("zhihu").setup({
  filetypes = {
    ---@type ZhihuFiletypeConfig
    typst = {
      -- Type indicates the conversion strategy
      type = "markdown",
      -- Optional: provide a custom Article base class
      -- If not provided, uses the default markdown/html Article class
      -- Article = require 'zhihu.article.html'.Article,
      
      -- Required: converter function that converts content to markdown
      -- This function receives the raw file content and should return markdown string
      converter = {
        -- ["in"] function is called to convert from Typst to Markdown
        ["in"] = require("my_converters").typst_to_markdown,
        -- ["out"] function is called for reverse conversion (Markdown to Typst)
        ["out"] = require("my_converters").markdown_to_typst,
      },
      
      -- Optional: title function that generates title from content
      -- This function receives the raw file content (before conversion) and returns a title string
      -- The generated title will be used when uploading/updating the article
      title = function(typst_content)
        -- Extract title from content, e.g., first heading or metadata
        return require("my_converters").extract_title_from_typst(typst_content)
        
        -- Example: Extract first line as title
        -- local first_line = typst_content:match("^[^\n]+")
        -- return first_line or "Untitled"
      end
    },
  }
})

-- Now you can use:
-- :edit zhihu://123.typ  (with typst converter) to edit a Typst article and upload as HTML
