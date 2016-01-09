pages = index cv
pages_html = $(patsubst %,%.html,$(pages))

all: $(pages_html) articles demos projects

.SECONDEXPANSION:
$(pages_html): $$(shell basename -s .html $$@).md ./include/style.css ./include/template.html
	pandoc $< -s --mathjax \
    --template=./include/template.html \
    --css=./include/style.css \
    --variable=webroot:. \
    -o $@

.PHONY: articles
articles:
	$(MAKE) -C ./articles

.PHONY: demos
demos:
	$(MAKE) -C ./demos

.PHONY: projects
projects:
	$(MAKE) -C ./projects

.PHONY: clean
clean:
	-rm -f *.html
	$(MAKE) -C ./articles clean
	$(MAKE) -C ./demos clean
	$(MAKE) -C ./projects clean
