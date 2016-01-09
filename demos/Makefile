pages = \
  index
pages_html = $(patsubst %,%.html,$(pages))
pages_md = $(patsubst %,%.md,$(pages))

all: html

html: $(pages_html)

.SECONDEXPANSION:
$(pages_html): $$(shell basename -s .html $$@).md ../include/style.css ../include/template.html
	pandoc $< -s --mathjax \
	  --template=../include/template.html \
	  --css=../include/style.css \
	  --variable=webroot:.. \
	  -o $@

clean:
	-rm -f *.html
