.PHONY: all
all: build wc

.PHONY: build
build:
	mkdir -p ./build
	cd ./build && ../configure && make

clean:
	rm -rf ./build

upload:
	tar cvz -C build glinjona-web-0.0.1 | ssh -l glinjona www2.cose.isu.edu 'cd /home/glinjona/public_html && rm -rf glinjona-web-* && tar xvz'

wc:
	find . -type f \( -name '*.md' -o -name '*.tex' \) \
		-exec cat '{}' \; | wc --words
