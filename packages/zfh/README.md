# Zhihu flavored HTML

<https://www.zhihu.com/api/v4/content/publish> uses a various HTML standard.
So we need a specification for it.

## Spec

We only record the difference from [standard HTML](https://html.spec.whatwg.org/multipage/).
We list by the order:

1. render result
2. [Github flavored markdown](https://github.github.com/gfm/)
3. Zhihu flavored HTML
4. [pandoc](https://pandoc.org/)'s HTML: `pandoc test.md`
5. [typst](https://typst.app/)'s HTML: `typst compile --features=html -f html test.typ`

### Fenced code blocks

```python
import numpy
```

``````markdown
```python
import numpy
```
``````

```html
<pre lang="python">import numpy</pre>
```

```html
<div class="sourceCode" id="cb1">
<pre class="sourceCode python">
<code class="sourceCode python">
<span id="cb1-1"><a href="#cb1-1" aria-hidden="true" tabindex="-1"></a>
<span class="im">import</span> numpy</span>
</code>
</pre>
</div>
```

```html
<pre><code data-lang="python"><span style="color: #d73948">import</span> numpy</code></pre>
```

### Images

![caption](https://pica.zhimg.com/80/v2-91c9434b826e4e271820b84637c0856c "title")

```markdown
![caption](https://pica.zhimg.com/80/v2-91c9434b826e4e271820b84637c0856c "title")
```

```html
<img src="https://pica.zhimg.com/80/v2-91c9434b826e4e271820b84637c0856c"
data-caption="caption" data-size="normal" data-watermark="watermark"
data-original-src="https://pica.zhimg.com/80/v2-91c9434b826e4e271820b84637c0856c"
data-watermark-src="" data-private-watermark-src="">
```

```html
<figure>
<img src="https://pica.zhimg.com/80/v2-91c9434b826e4e271820b84637c0856c"
title="title" alt="caption" />
<figcaption aria-hidden="true">caption</figcaption>
</figure>
```

typst doesn't allow online image.

### Inline math

$\alpha_1$

```markdown
$\alpha_1$
```

```html
<img eeimg="1" src="//www.zhihu.com/equation?tex=\alpha_1" alt="\alpha_1">
```

```html
<span class="math inline"><em>α</em><sub>1</sub></span>
```

warning: equation was ignored during HTML export

### Display math

$$\alpha_1$$

```markdown
$$\alpha_1$$
```

```html
<p><img eeimg="1" src="//www.zhihu.com/equation?tex=\alpha_1" alt="\alpha_1"></p>
```

```html
<p><span class="math display"><em>α</em><sub>1</sub></span></p>
```

warning: equation was ignored during HTML export

### Footnote

text[^1]

[^1]: footnote

```markdown
text[^1]

[^1]: footnote
```

```html
<p>text<sup class="footnote-reference"><a href="#1">1</a></sup></p>
<div class="footnote-definition" id="1"><sup class="footnote-definition-label">1</sup><p>footnote</p></div>
```

```html
<p>text<a href="#fn1" class="footnote-ref" id="fnref1"
role="doc-noteref"><sup>1</sup></a></p>
<section id="footnotes" class="footnotes footnotes-end-of-document" role="doc-endnotes">
<hr />
<ol>
<li id="fn1"><p>footnote<a href="#fnref1" class="footnote-back"
role="doc-backlink">↩︎</a></p></li>
</ol>
</section>
```

```html
<p>text<a id="loc-1" href="#loc-2" role="doc-noteref"><sup>1</sup></a></p>
<section role="doc-endnotes">
  <ol style="list-style-type: none">
    <li id="loc-2"><a href="#loc-1" role="doc-backlink"><sup>1</sup></a>footnote</li>
  </ol>
</section>
```

## Usage

This project provide a library to convert many markup languages to Zhihu
flavored HTML.

```lua
local text = "$\alpha_1$"
local md_to_html = require'markdown_to_html'.md_to_html
print(md_to_html(text))
```

Or use pandoc:

```sh
$ pandoc --lua-filter=bin/zfh /the/path/of/test.md
# or
$ zfh /the/path/of/test.md
# HTML output
```

## Related Projects

- [zhconv](https://github.com/pluveto/ZhihuFormulaConvert): convert LaTeX
  formula to zfh
- [md2zhihu](https://github.com/drmingdrmer/md2zhihu): convert markdown to zhihu
  markdown
