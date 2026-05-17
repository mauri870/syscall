NAME = syscall

CC      ?= gcc
CFLAGS  ?= -O2 -std=c99 -Wall -Wpedantic
LDFLAGS ?=
PREFIX  ?= /usr/local
BINDIR  ?= $(PREFIX)/bin
MANDIR  ?= $(PREFIX)/share/man/man1

SYSCALLS = read \
	   write \
	   open \
	   close \
	   lseek \
	   ioctl \
	   pread64 \
	   pwrite64 \
	   access \
	   pipe \
	   dup \
	   dup2 \
	   pause \
	   alarm \
	   getpid \
	   sendfile \
	   socket \
	   exit \
	   kill \
	   uname \
	   fcntl \
	   flock \
	   fsync \
	   fdatasync \
	   truncate \
	   ftruncate \
	   getcwd \
	   chdir \
	   fchdir \
	   rename \
	   mkdir \
	   rmdir \
	   symlink \
	   readlink \
	   chmod \
	   fchmod \
	   chown \
	   fchown \
	   lchown \
	   umask \
	   getuid \
	   syslog \
	   getgid \
	   setuid \
	   setgid \
	   link \
	   unlink \
	   stat \
	   fstat \
	   lstat \
	   mmap \
	   munmap \
	   wait4 \
	   geteuid \
	   getegid \
	   getpgrp \
	   nanosleep \
	   clock_gettime

all: $(NAME)

$(NAME): tab.h $(NAME).o
	$(CC) $(CFLAGS) -o $@ $(NAME).o $(LDFLAGS)

$(NAME).o: $(NAME).c tab.h
	$(CC) $(CFLAGS) -c $<

tab.h:
	@echo "Generating tab.h"
	@echo -n > tab.h
	@for s in $(SYSCALLS); do \
		echo "{ \"$$s\", SYS_$$s }," >> tab.h; \
	done
	@echo '{ 0, 0 },' >> tab.h

install: $(NAME)
	install -d $(BINDIR) $(MANDIR)
	install -m 755 $(NAME) $(BINDIR)/$(NAME)
	gzip -f -k $(NAME).1
	install -m 644 $(NAME).1.gz $(MANDIR)/$(NAME).1.gz

uninstall:
	rm -f $(BINDIR)/$(NAME) $(MANDIR)/$(NAME).1.gz

test: $(NAME)
	bats test/syscall.bats

clean:
	rm -f tab.h $(NAME).o $(NAME) $(NAME).1.gz

.PHONY: all install uninstall clean test
