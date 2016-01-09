% Using Pandoc, Etc. To Compile Static Websites

One of the hottest things around these days for building web pages, especially
personal blogs, is [Jekyll](https://jekyllrb.com/). Programmers are tired of
pretending to be system admins for server-side blog software like Wordpress or
Drupal, and the idea of writting their own HTML-formatted blog articles by hand
is unappealing to most. (Who wants to write HTML in their spare time?) So tools
for converting
[Markdown-formatted](https://daringfireball.net/projects/markdown/syntax) text
into blogs and such have exploded in popularity on GitHub. There's even a handy
list of them over at [StaticGen.com](https://www.staticgen.com/).

Personally, I've had as much trouble with static site generators
as with any heavyweight blog software. 

Moreover, I don't necessarily enjoy writing documents with Markdown any more
than I enjoy writing them with HTML. For certain documents, I would much rather
use LaTeX. It's honestly a matter of personal preferance more than anything
else.

That's why I've settled on a solution that uses a document conversion utility called Pandoc, along with 

## Taking Pandoc for a Spin
[Pandoc](http://pandoc.org/) is one of a few tools that promises to convert
LaTeX documents into HTML. It can do much more than that, however, which can be
seen just by taking a peek at its [sprawling user
guide](http://pandoc.org/README.html).

This following command works wonderfully for converting (relatively simple)
LaTeX documents to HTML documents suitable for a webpage.

    pandoc test.tex -s --mathjax -o test.html

The `--mathjax` flag makes for lovely math typography using
[MathJax](https://www.mathjax.org/), all with HTML!


## Adding More Pages
One of the 

## Customizing Pandoc Output

## Adding Comment Sections
A blog is a pretty lonesome place without comments. Sure, I could just slap my
e-mail address at the bottom of the page and call it good.

The [universal code for Disqus](https://disqus.com/admin/universalcode/) is
pretty straightforward to add to a website. The only provision for using it is
placing the URL for one's webpage in their provided code. Pandoc's template
system ought to do the trick.

## Automating Everything with GNU Make
GNU Make and Autotools can be used for purposes other than compiling C code.
There are [several](http://lincolnmullen.com/blog/make-and-pandoc/)
[existing](http://wcm1.web.rice.edu/colophon.html)
[tutorials](https://tylercipriani.com/2014/05/13/replace-jekyll-with-pandoc-makefile.html)
for automating Pandoc websites with Bash or Make, so don't take my word for it.
Personally, I use Make for the flexibility it offers me when building
[Emscripten](http://emscripten.org)-generated content for my
[project](../projects/index.html) or [demo](../demos/index.html) pages.

Note that I make no attempt to conform to any [Makefile
conventions](http://www.gnu.org/prep/standards/standards.html#Makefile-Conventions)
in this article. Improvements along those lines should be directed to my [git
repository](#).

To start off with the automation, here is a basic `Makefile` for building the
articles on this website. This version does not include any Autotools macros.

~~~{.makefile}
pages = pandoc octree index
pages_html = $(patsubst %,%.html,$(pages))

all: html

html: $(pages_html)

.SECONDEXPANSION:
$(pages_html): $$(shell basename -s .html $$@).md \
                ../include/style.css ../include/template.html
	pandoc $< -s --mathjax \
	  --template=../include/template.html \
	  --css=../include/style.css \
	  --variable=webroot:.. \
	  -o $@

clean:
	-rm -f *.html
~~~

Here I'm building three pages, `pandoc.html`, `octree.html`, and `index.html`
from their corresponding Markdown files. The Pandoc flags discussed above are
included. Notice that in this case `webroot` is located in the containing `..`
directory.

The confusing bits of this `Makefile` are features of GNU Make such as
[`patsubst`](https://www.gnu.org/software/make/manual/html_node/Text-Functions.html),
[`SECONDEXPANSION`](https://www.gnu.org/software/make/manual/html_node/Secondary-Expansion.html),
and [automatic
variables](https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html),
which I use to manipulate the list of pages into targets for the `.html` files
that I want to generate. I could just have easily used [pattern
rules](https://www.gnu.org/software/make/manual/html_node/Pattern-Intro.html)
with a wildcard to make targets for all `.md` files, but I prefer making my own
list.

## Using Autotools for Out-Of-Tree Builds and Deployment

I use Autotools because out-of-tree builds (and thus website deployments) are
much easier to pull off with the macros that Autotools provides. 

The Autotools macro we need in particular is `srcdir` along with the GNU Make
`VPATH` variable. Page 68 of the book [Autotools, A Practicioner's Guide to GNU
Autoconf, Automake, and Libtool](https://www.nostarch.com/autotools.htm) by
[John Calcote](https://jcalcote.wordpress.com/about/) lays out a
straightforward method of converting an ordinary `Makefile` into one that uses
`srcdir` and `VPATH` to support separate build directories.


## Forkable Pandoc+Autotools Website
In the hopes that my efforts to build a LaTeX-friendly blog/homepage might be
useful to someone else, I have uploaded a [public repository on GitHub](#) that
anyone can fork to create their own site using Pandoc and Autotools. The
template site has everything one should need for a blog or homepag, sans
content.

I use a fork of the same template repository for this very website,
and synchronize the two from time to time.  Patches are also welcome.
