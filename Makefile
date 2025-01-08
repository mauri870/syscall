NAME = syscall

CC ?= gcc
CFLAGS=-std=c99 -Wall -Wpedantic
PREFIX ?= /usr/local

all: gen $(NAME)

gen:
	bash gensys.sh

install: $(NAME)
	install -m 755 $< $(PREFIX)/bin/$(NAME)
	gzip -f -k $<.1
	install -m 644 $<.1.gz $(PREFIX)/share/man/man1/$<.1.gz

uninstall:
	rm $(PREFIX)/bin/$(NAME) $(PREFIX)/share/man/man1/$(NAME).1.gz

clean:
	-rm -f syscalls_generated.c
	-rm -f $(NAME).o
	-rm -f $(NAME)
	-rm -f $(NAME).1.gz
