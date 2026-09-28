<!-- markdownlint-disable MD041 -->
<!-- markdownlint-disable MD033 -->
<p align="center">
  <img width="150" alt="favicon" src="https://github.com/user-attachments/assets/c99c26d9-f07d-4f3e-bdc4-dae632ab8f45"/>
</p>
<!-- markdownlint-enable MD033 -->

# :alien: Zhihu On NeoVim

基于 NeoVim 的知乎客户端提供包括~阅读~，~搜索~，创作，发布等一站式服务，内容加载速度比 Web 端更快，创新的 Markdown-Latex 混合语法让内容创作者更方便地插入代码块，数学公式，并一键发布至知乎平台。

## :zap: Features

- [x] 登录
- [x] 创作
  - [x] 内容创作
  - [x] 内容发布
  - [x] 一键上传图片
  - [ ] 定时发布
- [ ] 浏览

## :key: 登录

按以下顺序搜索登录需要的 cookies :

- 火狐浏览器： `~/.mozilla/firefox/*.default/cookies.sqlite`
- 谷歌浏览器： `~/.config/google-chrome/Default/Cookies`
- 调试： `~/.local/state/nvim/cookies.json`

覆盖根据优先级找到的 cookies 是可行的。对于在不同浏览器登录不同的知乎账户的用户，
可以强行指定用谷歌浏览器 cookies 覆盖自动搜索到的 cookies:

```lua
require 'zhihu.api'.auth = require 'auth.chrome'.Auth()
```

更多用法请参考 [auth](packages/auth) 文档。

编辑保护：检测到当前打开的知乎文章、回答的作者不是你时会将缓冲区设为只读模式：

```lua
require 'zhihu'.setup {
    article = {
        authorName = "your zhihu account name"
    }
}
```

TODO: 自动获取用户名。

## :crayon: 内容创作

将你要编辑的知乎回答的 URL 开头的 `http://` 或 `https://` 替换为 `zhihu://`
并添加合适的文件后缀即可：

在 Shell 中：

```bash
vi zhihu://www.zhihu.com/question/question_id/answer/answer_id.md
```

在 Vim 中：

```vim
:edit zhihu://www.zhihu.com/question/question_id/answer/answer_id.md
```

![edit](https://github.com/user-attachments/assets/18640c04-5e02-4f09-9065-3f8dc644afab)

专栏文章同理：

```vim
:edit https://zhuanlan.zhihu.com/p/article_id.md
```

创建新的回答或专栏文章只需把对应的 id 替换为 new :

```vim
:edit https://zhuanlan.zhihu.com/p/new.md
```

编辑不存在的链接时会遇到 404:

```vim
:edit zhihu://0.md
```

```markdown
# 404

你似乎来到了没有知识存在的荒原

[去往首页](https://www.zhihu.com)
```

可以使用 markdown 以外的格式。内置对 typst 和 HTML 的支持。

```vim
:edit zhihu://www.zhihu.com/question/question_id/answer/answer_id.typ
:edit zhihu://www.zhihu.com/question/question_id/answer/answer_id.html
```

对于其他格式，需要安装 pandoc 进行转译：

```vim
:edit zhihu://www.zhihu.com/question/question_id/answer/answer_id.rst
```

可自定义转译方式。比如使用外部的 typst 将 typst 文件转译为 HTML:

```lua
require 'zhihu'.setup {
  article = {
    writer = function(...)
      if vim.o.filetype == 'typst' then
        return require'zfh.translator.cmd'.writer.typst(...)
      end
      return ...
    end
  }
}
```

事实上知乎只接受一种特殊的 HTML ，所有文件格式都需要转换为这种 HTML 才会被接受。
通过测试可以得到一些非官方的[语法规范](packages/zfh)。如果要在 markdown 插入
HTML 也必须遵循该规范。

### 数学公式

该规范仅允许 TeX 格式的数学公式，甚至不支持 HTML 的 MathML 。
对于 typst 也必须使用使用 LaTeX 数学公式：

```typst
#import "@preview/mitex:0.2.7": mi as _mi, mitex as _mitex
#let mitex(it) = context if target() == "html" {
  html.elem("p", attrs: (style: "display: flex; justify-content: center;"))[
    #html.elem("img", attrs: (
      src: "//www.zhihu.com/equation?tex=" + it.text,
      eeimg: "1",
      alt: it.text,
    ))
  ]
} else {
  _mitex(it)
}
#let mi(it) = context if target() == "html" {
  html.elem("img", attrs: (src: "//www.zhihu.com/equation?tex=" + it.text, eeimg: "1", alt: it.text))
} else {
  _mi(it)
}
#mi(`det(A * I) \geqslant det(A) = det(AI)`)
```

### 图片

typst 图片插入要求图片必须在本地。然而知乎要求所有图片必须上传到知乎图床，所以
必须使用如下语法：

```typst
#html.img(alt: "", src: "https://pica.zhimg.com/50/v2-5e6ef69d07eba3e2e69e6b8bddd74e6b_720w.jpg?source=2c26e567")
```

### 代码块

该规范导致必须 typst 要在使用代码块前额外编写如下代码：

``````typst
#show raw.where(block: true): it => context if target() == "html" {
  html.elem("pre", attrs: (lang: it.lang))[#it.text]
} else { it }

```json
{
  "version": "2.0.0",
  "request": {
      "Configuration": { }
    }
}
```
``````

综上所述，所以现在反而是 markdown 在转译生成知乎 HTML 上更加方便。

此外， typst 的语言服务器 tinymist 在检测到 `zhihu://` 开头的文件时会停止工作。
这是上游的 [bug](https://github.com/Myriad-Dreamin/tinymist/issues/2417) 。
因为 markdown 的[语言服务器](https://github.com/jolars/panache)是可以工作的。

中文编辑推荐插件：

中文输入法：

- [rime.nvim](https://github.com/rimeinn/rime.nvim)
- [fcitx5-ui.nvim](https://github.com/black-desk/fcitx5-ui.nvim)
- [ZFVimIM](https://github.com/ZSaberLv0/ZFVimIM)
- [ime.nvim](https://github.com/rimeinn/ime.nvim)
- [fcitx.vim](https://github.com/lilydjwg/fcitx.vim)
- [vim-xkbswitch](https://github.com/lyokha/vim-xkbswitch)

中文分词:

- [jieba.nvim](https://github.com/neo451/jieba.nvim)
- [jieba.vim](https://github.com/kkew3/jieba.vim)

中文标点符号:

- [vim-smartinput-extra](https://github.com/Vim-cn/vim-smartinput-extra)

## :envelope_with_arrow: 内容发布

在编辑器预览的插件：

- [math-conceal.nvim](https://github.com/pxwg/math-conceal.nvim)
- [markview.nvim](https://github.com/OXY2DEV/markview.nvim)
- [latex_concealer.nvim](http://github.com/dirichy/latex_concealer.nvim)
- [tex-conceal.vim](https://github.com/KeitaNakamura/tex-conceal.vim)

在网页浏览器预览的插件：

- [coc-markdown-preview-enhanced](https://github.com/weirongxu/coc-markdown-preview-enhanced)
- [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)

但注意并不是以上插件支持预览的所有 markdown 语法都被知乎支持。比如 Mermaid 。

预览完就可以发布了。发布就像保存一个普通文件一样轻松：

```vim
:write
```

你可以定义快捷键浏览发布后的回答或专栏文章。
如果还未发布，该快捷键会打开对应的问题或首页。

```vim
:nnoremap <localleader>lv :lua require'zhihu.nvim'.open()<CR>
```

定义[菜单栏选项](https://github.com/skywind3000/vim-quickui)也是可以的。

![menu](https://github.com/user-attachments/assets/ff79e942-7221-4caf-bde6-d8d376d0a58b)

对于知乎专栏文章，你在发布前需要额外设置标题：

```vim
:let b:article.title = "Title"
:write
```

TODO： 如果文章标题为空则从第一个 `<h1>` 标签获取标题。

更多选项是可以设置的，例如：

开启送礼物：

```vim
:let b:article.can_reward = v:true
```

允许转载：

```vim
:let b:article.reshipment_settings = "allowed"
```

以上设置是临时的，需要永久设置的话请在配置文件中加入：

```lua
require 'zhihu'.setup {
  article = {
    can_reward = true,
    reshipment_settings = "allowed"
  }
}
```

具体设置参见 `lua/zhihu/_meta.lua` 。

## :bar_chart: 一键上传图片

```lua
:inoremap <C-Q> <C-O>:lua require 'zhihu.nvim'.input()<CR>
```

在对话框中插入本地图片路径开始上传。上传成功后默认会写入到剪贴板。

![image](https://github.com/user-attachments/assets/a6e7bc3e-5243-4d15-82c5-5e9ca676934d)

你可以定义一些上传选项，例如

<!-- markdownlint-disable MD013 -->
```lua
:inoremap <C-Q> <C-O>:lua require 'zhihu.nvim'.input {src_type = 'watermark_src', regnames = {'*', '+', '.', 'a'}}<CR>
```
<!-- markdownlint-enable MD013 -->

会将带有水印的图片路径写入到 2 个系统剪贴板、当前光标所在和 a 号寄存器。

- Unix 有两个系统剪贴板 `*` 和 `+` ，分别通过 `<C-C>`/`<C-V>` 以及鼠标选中/鼠标中键写入和写出。
  在不支持第 2 个剪贴板的操作系统上会被识别为同一个剪贴板。
- `.` 会插入当前光标位置。不建议这样做，因为上传是异步的，很可能你已经编辑到别的位置了。
- a 号寄存器的内容可以通过 `:echo @a` 查看。更多内容请参阅 `:help :registers`
- 无法写入只读寄存器 `%`, `#`, `:`

上传需要时间。如果超时请重试。也可以增大上传次数到 30 和上传间隔时间到 3 秒：

<!-- markdownlint-disable MD013 -->
```lua
:inoremap <C-Q> <C-O>:lua require 'zhihu.nvim'.input {max_retry = 30, sleep_seconds = 3}<CR>
```
<!-- markdownlint-enable MD013 -->

## 插件集成

### [nerdfont.vim](https://github.com/lambdalisue/nerdfont.vim)

```vim
let g:nerdfont#path#pattern#customs = {
      \ '^zhihu://': '',
      \ }
```

### [vim-airline](https://github.com/vim-airline/vim-airline)

```vim
let g:airline#extensions#tabline#formatter = 'zhihu'
```

### [nvim-notify](https://github.com/rcarriga/nvim-notify)

```lua
vim.notify = require "notify"
vim.notify.setup({
    background_colour = "#000000",
})
```

### [vim-browser-search](https://github.com/voldikss/vim-browser-search)

```vim
autocmd BufNewFile zhihu://* let b:browser_search_default_engine = 'zhihu'
```

## API

### Update zhihu article

```lua
local Article = require 'zhihu.article'.Article
local id = "your_article_id"
local article
if id then
  article = Article:from_id(id)
  -- or create an article
else
  article = Article { title = "title" }
end
local f = io.open "/the/path/of/your/article.html"
if f then
  local html = f:read "*a"
  f:close()
  article:set_content(html)
  article:write()
end
```

### Upload image to zhihu

```lua
local Uploader = require 'zhihu.image'.Uploader
local fetch = require 'zhihu.image'.fetch_image_sync
local uploader = Uploader.from_file '/the/path/of/image.png'
local id = tostring(uploader)
local image = fetch(id)
print(image)
-- https://picx.zhimg.com/v2-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

### Convert markdown and HTML

```lua
local md_to_html = require 'markdown_to_html'.md_to_html
local html_to_md = function(html)
    return require 'zhihu.article.generator.markdown'.generator:translate(html)
end
local markdown = "# Title"
assert(markdown == html_to_md(md_to_html(markdown)))
```

## Install

### rocks.nvim

#### Command style

```vim
:Rocks install zhihu.nvim
```

#### Declare style

`~/.config/nvim/rocks.toml`:

```toml
[plugins]
"zhihu.nvim" = "scm"
```

Then

```vim
:Rocks sync
```

or:

```sh
$ luarocks --lua-version 5.1 --local --tree ~/.local/share/nvim/rocks install zhihu.nvim
# ~/.local/share/nvim/rocks is the default rocks tree path
# you can change it according to your vim.g.rocks_nvim.rocks_path
```

### lazy.nvim

```lua
return {
  "pxwg/zhihu.nvim",
  main = "zhihu",
}
```

## Similar Projects

- [zhihu_obsidian](https://github.com/dongguaguaguagua/zhihu_obsidian)
- [VSCode-Zhihu](https://github.com/niudai/VSCode-Zhihu)
