% Compiling a Website with Pandoc
% Jonathan Glines
% 2016-04-19

One of the hottest things around these days for building web pages, especially
personal blogs, is [Jekyll](https://jekyllrb.com/). People are tired of using
server-side blog software like Wordpress or Drupal, but at the same time the
idea of writting HTML by hand is unappealing. (Who wants to write HTML code in
their spare time?) So tools for converting
[Markdown-formatted](https://daringfireball.net/projects/markdown/syntax) text
into websites and blogs have exploded in popularity on GitHub. There's even a
handy list of them over at [StaticGen.com](https://www.staticgen.com/).

I don't necessarily enjoy writing documents with Markdown any more than I enjoy
writing them with HTML. For certain documents, especially documents containing
math, I would much rather use LaTeX.  That's why I've settled on a static
website generating solution that uses a document conversion utility called
Pandoc.

## Taking Pandoc for a Spin
[Pandoc](http://pandoc.org/) is one of a few tools that promises to convert
LaTeX documents into HTML. It can do much more than that; just take peek at its [sprawling user
guide](http://pandoc.org/README.html).

To get started, the following command works wonderfully for converting Markdown
documents to HTML documents suitable for a webpage.

~~~{.bash}
$ pandoc test.md -s -o test.html
~~~

The exact same utility can be used for generating webpages from LaTeX
documents, as in this command:

~~~{.bash}
$ pandoc test.tex -s --mathjax -o test.html
~~~

The `--mathjax` flag makes for lovely math typography using
[MathJax](https://www.mathjax.org/), all with HTML!

Of course, if things were that easy, we wouldn't really have a website, at
least not one that we could call *our website*. The following sections build
upon the `pandoc` command with other tools.

## Automating Everything

GNU Make and Autotools can be used for purposes other than compiling C code.
There are [several](http://lincolnmullen.com/blog/make-and-pandoc/)
[existing](http://wcm1.web.rice.edu/colophon.html)
[tutorials](https://tylercipriani.com/2014/05/13/replace-jekyll-with-pandoc-makefile.html)
for automating Pandoc websites with Bash or Make, so don't take my word for it.
Personally, I use Make for the flexibility it offers me when I need to reach
for other tools, such as when building
[Emscripten](http://emscripten.org)-generated content.

Note that while I try to keep these Makefiles reasonable, I make no attempt to
conform to any [Makefile
conventions](http://www.gnu.org/prep/standards/standards.html#Makefile-Conventions)
in this article. If we were building a software package for distribution such
conventions might be a concern. 

### Basic Makefile
To start off with automating our website, we create a very basic `Makefile`
that builds a single page. This `Makefile` does not include any Autotools
macros or other nifty tricks (yet) to start us off simple. I will be
introducing such tricks to this example throughout the article.

~~~{.makefile}
all: index.html

index.html: index.md ./include/style.css ./include/template.html
	pandoc $< -s --mathjax \
		--template=./include/template.html \
		--css=./include/style.css \
		-o $@

clean:
	-rm -f *.html
~~~

This is a very simple `Makefile`, which is as good as any when starting a
website.

Notice that I've added a `--template` and `--css` flag to my invocation of the
`pandoc` command. This is how I customize the layout and style of my page.
These flags are explained in the [Pandoc user
guide](http://pandoc.org/README.html).

The `style.css` file should be pretty straightforward for anyone who's designed
a website. No surprises here.

`template.html` on the other hand is a bit more interesting. Pandoc has [many
options for generating documents from
templates](http://pandoc.org/README.html#templates).  I'm using the template
feature of Pandoc to tweak the layout of my pages, as well as to generate a
header, footer, and navigation bar for each page.

The easiest way to get started with a Pandoc template is to generate one from
the default template, such as with the following command.

~~~{.bash}
$ mkdir ./include
$ pandoc -D html > ./include/template.html
~~~

The syntax for Pandoc's templates should be apparent just by looking at the
default template that `pandoc -D` generates. For a more detailed description of
templates, just look in the [Pandoc user
guide](http://pandoc.org/README.html#templates).


### Adding More Pages
Obviously, automating the process of building one webpage is not going to save
us much effort. Things really get interesting when we start adding more pages
to our `Makefile`.

We could always simply copy and paste the `index.html:` target in our
`Makefile` to add new pages.  This method is far from ideal, however, as we
would need to duplicate several lines in our `Makefile` for every page we add.
Moreover, changing flags for the `pandoc` command for every page would be
unworkable.

A much better solution is to have GNU Make create the targets for new pages
automatically.

~~~{.makefile}
pages = pandoc octree index
pages_html = $(patsubst %,%.html,$(pages))

all: html

html: $(pages_html)

.SECONDEXPANSION:
$(pages_html): $$(shell basename -s .html $$@).md \
		./include/style.css ./include/template.html
	pandoc $< -s --mathjax \
		--template=./include/template.html \
		--css=./include/style.css
		-o $@

clean:
	-rm -f *.html
~~~

This builds three pages, `pandoc.html`, `octree.html`, and `index.html`,
from their corresponding Markdown files.

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

### Adding a Tree Structure
At this point we have several pages in the root of our website's directory, but
we don't have any subdirectories.

The tricky bit when creating a tree hierarchy in a website is that the relative
links in the navigation bar need to change for each level in the hierarchy. For
example, if I were to link to my homepage from the page
`./articles/index.html`, I would need to use the relative link `../index.html`.
However, if I were linking from the page `./prod/demos/rt/index.html`, I
would need to use the relative link `../../../index.html`. This quickly becomes
a huge headache, especially when the navigation bar contains several links.

The solution to this problem is simple: templates. I'll start by showing the
snippet of templatized HTML code that defines my navigation bar.

~~~{.html}
<!-- doctype omitted -->
<head>
<!-- head omitted -->
</head>
<body>
<div id="pageHeader">
<div id="navigation">
<a href="$webroot$/index.html">MAIN PAGE</a>
<a href="$webroot$/articles/index.html">ARTICLES</a>
<a href="$webroot$/productions/index.html">PRODUCTIONS</a>
<a href="$webroot$/cv.html">CV</a>
</div>
</div>
<!-- body content omitted -->
</body>
~~~

Notice that in this case `webroot` is located in the containing `..`
directory. This is important for making header links work, as we'll see later.

## Out-Of-Tree Builds and Deployment

I use Autotools for out-of-tree builds of my website. It's difficult (although
not impossible) to do out-of-tree builds with GNU Make alone. Out-of-tree
builds are much easier to pull off with the macros that Autotools provides.

The Autotools macro we need in particular is `srcdir` along with the GNU Make
`VPATH` variable. Page 68 of the book [Autotools, A Practicioner's Guide to GNU
Autoconf, Automake, and Libtool](https://www.nostarch.com/autotools.htm) by
[John Calcote](https://jcalcote.wordpress.com/about/) lays out a
straightforward method of converting an ordinary `Makefile` into one that uses
`srcdir` and `VPATH` to support separate build directories. I highly recommend
grabbing that book if you find yourself scratching your head when dealing with
Autotools.

~~~{.makefile}
pages = pandoc octree index
pages_html = $(patsubst %,%.html,$(pages))
pages_md = $(patsubst %,%.md,$(pages))

srcdir = @srcdir@
top_srcdir = @top_srcdir@
top_builddir = @top_builddir@
VPATH = @srcdir@

all: html

html: $(pages_html)

.SECONDEXPANSION:
$(pages_html): $$(shell basename -s .html $$@).md \
		$(top_srcdir)/include/template.html \
		$(top_builddir)/include/style.css \
		$(top_srcdir)/include/ieee.csl
	pandoc $< -s --mathjax \
		--bibliography $(srcdir)/references.bib \
		--csl $(top_srcdir)/include/ieee.csl \
		--template=$(top_srcdir)/include/template.html \
		--css=$(top_builddir)/include/style.css \
		--variable=webroot:.. \
		-o $@

clean:
	-rm -f *.html
~~~

Here I've added an optional bibliography using IEEE style formatting. As
always, more information about that can be found in the [Pandoc user
guide](http://pandoc.org/README.html#citation-rendering).

More importantly, I'm using autotools now, and this file is now named `Makefile.in`. It contains autotools macros (actaully M4 macros if I'm not mistaken), surrounded by `@` symbols. Autotools will use this file to generate the actual `Makefile` that `make` will use. We need to tell autotools about our `Makefile.in` files in the following `configure.ac` file.

~~~{.m4}
AC_INIT([website], [0.0.1])
AC_CONFIG_FILES([
    Makefile
    include/Makefile
    articles/Makefile
    productions/Makefile
    productions/billiards/Makefile
])

AC_OUTPUT
~~~

On my website I'm using several folders with several `Makefile.in` files.

The following sequence of commands will make the `./configure` script and build
the website inside a build directory.

~~~{.bash}
$ autoconf
$ mkdir ./build
$ cd ./build
$ ../configure
configure: creating ./config.status
config.status: creating Makefile
config.status: creating articles/Makefile
config.status: creating productions/Makefile
$ make
~~~

## Other Things
So far I've only talked about the nuts and bolts of automatically generating a
website. Now I'm going to lay out some of the nifty things I've done with these
scripts. Flexibility was my main motive for using Pandoc with GNU Make and
Autotools, so I expect this section to expand as I discover new features to add
to my website.

### Build Faster with Multiple Jobs
GNU Make provides a `-j` flag which specifies the number of jobs that Make will
dispatch simultaneously. Using as many jobs as one has CPU cores can
drastically cut down on the time it takes to generate a Pandoc website. Here is
the command I use on my quad core destop with Hyperthreading.

~~~{.bash}
$ make -j8
~~~

And here is the command I would use on my netbook with only two cores.

~~~{.bash}
$ make -j2
~~~

You would think this would be obvious to anyone familiar with GNU Make, but
honestly I forget the `-j` flag half of the time whenever I'm engrossed in a
project. I like to automate the things I forget to do, so it's only natural
that I arrived at the following.

~~~{.bash}
$ make -j$(grep -c "^processor" /proc/cpuinfo)
~~~

Stick that line into your bash aliases, a shell script, or another Makefile; I
don't care. This line of code will check how many processors are available
before invoking `make` with the appropriate `-j` flag. Obviously it will only
work on Linux operating systems. For the rest of your systems, just use a
number.

### Bibliography Generation
In the code samples above, I make use of the bibliography flag of Pandoc. This
flag allows one to use the BibTeX command, which should be familiar to any user
of LaTeX, to generate citations and reference sections in any document, not
just TeX documents. Here is a `references.bib` file I have used with Pandoc's
`--bibliography` flag.

~~~{.latex}
@book{Deloura2000,
 author = {Deloura, Mark.},
 title = {Game Programming Gems},
 year = {2000},
 isbn = {1584500492},
 publisher = {Charles River Media, Inc.},
 address = {Rockland, MA, USA},
} 
@book{Gregory2009,
  author = {Gregory, Jason.},
  title = {Game Engine Architecture},
  year = {2009},
  isbn = {9781568814131},
  publisher = {A K Peters, Ltd.},
  address = {Natick, MA, USA},
}
~~~

The `--csl` flag specifies a file that determines the citation style. I use the
IEEE style familiar to engineers. The appropriate `ieee.csl` file [can be found
easily on
GitHub](https://github.com/citation-style-language/styles/blob/master/ieee.csl).

Once a `.bib` file and citation style have been specified, citations be easily
made within markdown text with the following syntax.

~~~{.markdown}
The matrix that transforms a vertex into its new position
corresponding to the pose of the skeleton is called the
skinning matrix. [@Gregory2009]
~~~

### Generating PDF Documents
Most of my articles can be downloaded as PDF documents. These documents are all
automatically generated by Pandoc (of course) and the following make target.

~~~{.makefile}
pages_pdf = $(patsubst %,%.pdf,$(pages))

.SECONDEXPANSION:
$(pages_pdf): $$(shell basename -s .pdf $$@).md \
		$(top_srcdir)/include/ieee.csl
	pandoc $< -s \
		--bibliography $(srcdir)/references.bib \
		--csl $(top_srcdir)/include/ieee.csl \
		-o $@
~~~

### Comment Sections
A blog is a pretty lonesome place without comments. Sure, I could just slap my
e-mail address at the bottom of the page and call it good.

The [universal code for Disqus](https://disqus.com/admin/universalcode/) is
pretty straightforward to add to a website. The only provision for using it is
placing the URL for one's webpage in their provided code. Pandoc's template
system will do the trick.

### Website Word Count
I like to know how many words I've written in a day as a way to measure my
writing goals. Some days it can be difficult to determine my total word count,
especially when I'm juggling multiple articles.

The solution to this is practically a one-line bash script. I stick
it under a target called `wc:` in the `Makefile` at the root of my website.

~~~{.makefile}
wc: pages
	find . -type f \( -name '*.md' -o -name '*.tex' \) \
		-exec cat '{}' \; | wc --words
~~~

### Combine Multiple Files Into One Page
From the Pandoc user's guide:
 
>If multiple input files are given, pandoc will concatenate them all (with
>blank lines between them) before parsing.

This can be used for lengthy articles or for chapters in a book.

## Forkable Pandoc+Autotools Website
In the hopes that my efforts to build a LaTeX-friendly blog/homepage might be
useful to someone else, I have uploaded a [public repository on GitHub](#) that
anyone can fork to create their own site using Pandoc and Autotools. The
template site has everything one should need for a blog or homepag, sans
content.

I use a fork of the same template repository for this very website,
and synchronize the two from time to time.  Patches are also welcome.
