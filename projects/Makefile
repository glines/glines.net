pages = index berb pib

pages_html = $(patsubst %,%.html,$(pages))

all: $(pages_html)

.SECONDEXPANSION:
$(pages_html): $$(shell basename -s .html $$@).md ../include/style.css ../include/template.html
	pandoc $< -s --mathjax \
    --template=../include/template.html \
    --css=../include/style.css \
    --variable=webroot:.. \
    -o $@

.PHONY: berb
berb:
	$(MAKE) -C ./berb

.PHONY: pib
pib:
	$(MAKE) -C ./pib

.PHONY: clean
clean:
	-rm -f *.html
	$(MAKE) -C ./berb clean
	$(MAKE) -C ./pib clean
