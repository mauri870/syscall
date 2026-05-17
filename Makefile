NAME = syscall

CC      ?= gcc
CFLAGS  ?= -O2 -std=c99 -Wall -Wpedantic
LDFLAGS ?=
PREFIX  ?= /usr/local
BINDIR  ?= $(PREFIX)/bin
MANDIR  ?= $(PREFIX)/share/man/man1

all: $(NAME)

$(NAME): tab.h $(NAME).o
	$(CC) $(CFLAGS) -o $@ $(NAME).o $(LDFLAGS)

$(NAME).o: $(NAME).c tab.h
	$(CC) $(CFLAGS) -c $<

tab.h:
	@echo "Generating tab.h"
	@echo | $(CC) -E -dM -include sys/syscall.h - \
		| grep '#define SYS_' \
		| sort \
		| awk '{print "{ \"" substr($$2,5) "\", " $$2 " },"}' \
		> tab.h
	@echo '{ 0, 0 },' >> tab.h

install: $(NAME)
	install -d $(BINDIR) $(MANDIR)
	install -m 755 $(NAME) $(BINDIR)/$(NAME)
	gzip -f -k $(NAME).1
	install -m 644 $(NAME).1.gz $(MANDIR)/$(NAME).1.gz

uninstall:
	rm -f $(BINDIR)/$(NAME) $(MANDIR)/$(NAME).1.gz $(PREFIX)/man/man1/$(NAME).1.gz

test: $(NAME)
	bats test/syscall.bats

clean:
	rm -f tab.h $(NAME).o $(NAME) $(NAME).1.gz

.PHONY: all install uninstall clean test
