pages = \
  pandoc \
  taocp \
  octree \
  boids \
  depth_peeling \
  beers_law \
  sdf \
  tunnel \
  meshes_flex_bison \
  index
pages_html = $(patsubst %,%.html,$(pages))
pages_pdf = $(patsubst %,%.pdf,$(pages))
pages_md = $(patsubst %,%.md,$(pages))

all: html pdf

html: $(pages_html)

.SECONDEXPANSION:
$(pages_html): $$(shell basename -s .html $$@).md ../include/style.css ../include/template.html
	pandoc $< -s --mathjax \
	  --filter pandoc-citeproc \
	  --template=../include/template.html \
	  --css=../include/style.css \
	  --variable=webroot:.. \
	  -o $@

pdf: $(pages_pdf)

.SECONDEXPANSION:
$(pages_pdf): $$(shell basename -s .pdf $$@).md
	pandoc $< -s \
	  --filter pandoc-citeproc \
	  --bibliography meshes_flex_bison.bib \
	  -o $@

clean:
	-rm -f *.html *.pdf
