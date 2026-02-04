---
-- Example: How to setup zhihu.nvim with custom filetypes
-- 
-- This file demonstrates two patterns for adding custom file converters:
-- 1. markdown_to_html: Convert to markdown first, then to HTML
-- 2. direct_html: Convert directly to HTML
---

-- Assume you have installed zhihu.nvim with lazy.nvim or rocks.nvim

-- Pattern 1: Using markdown_to_html (convert via markdown intermediate format)
-- Example: Typst -> Markdown -> HTML
require("zhihu").setup({
  filetypes = {
    typst = {
      -- Type indicates the conversion strategy
      type = "markdown_to_html",
      -- Optional: provide a custom Article base class
      -- If not provided, uses the default html Article class
      -- Article = require 'zhihu.article.html'.Article,
      
      -- Optional: template prefix to prepend to each article
      -- This is added at the beginning when reading/saving the article
      template_prefix = [[#quote(block: true, [本文使用 #link("https://github.com/pxwg/zhihu.nvim")[Zhihu on NeoVim] 创作并发布])]],
      
      -- Required: converter function that converts content to markdown
      -- This function receives the raw file content and should return markdown string
      converter = function(typst_content)
        -- Example: use a typst-to-markdown converter
        -- You can call external tools or use a pure Lua implementation
        return require("my_converters").typst_to_markdown(typst_content)
        
        -- Alternative: Call an external command
        -- local handle = io.popen('typst-md-convert /dev/stdin', 'r')
        -- ... read and return result
      end
    },
    
    -- Pattern 2: Using direct_html (convert directly to HTML)
    -- Example: RST -> HTML
    rst = {
      type = "direct_html",
      
      -- Optional: template prefix to prepend to each article
      -- For direct_html, it's prepended as-is
      template_prefix = "<blockquote><p>This article was created with Zhihu on NeoVim</p></blockquote>",
      
      -- Required: direct_converter function that converts content directly to HTML
      -- This function receives the raw file content and should return HTML string
      direct_converter = function(rst_content)
        -- Example: use a rst-to-html converter
        return require("my_converters").rst_to_html(rst_content)
      end
    },
    
    -- Pattern 3: Custom Article class with markdown_to_html
    -- This is useful if you need to override get_lines() or tostring() behavior
    custom = {
      type = "markdown_to_html",
      
      -- Custom Article class that inherits from html Article
      Article = require('zhihu.article.custom.custom_article').CustomArticle,
      
      -- Optional: template prefix for this specific filetype
      template_prefix = "Custom prefix for this format",
      
      converter = function(content)
        -- Custom conversion logic
        return require("my_converters").custom_format_to_markdown(content)
      end
    }
  }
})

-- Now you can use:
-- :edit zhihu://123.typ  (with typst converter) to edit a Typst article and upload as HTML
-- :edit zhihu://456.rst   (with rst converter) to edit an RST article and upload as HTML
-- :edit zhihu://789.custom (with custom Article class) to edit a custom format
