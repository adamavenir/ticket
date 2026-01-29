PREFIX ?= /usr/local

.PHONY: test install uninstall

test:
	uv run --with behave behave

install:
	install -m 755 ticket $(PREFIX)/bin/tk

uninstall:
	rm -f $(PREFIX)/bin/tk
