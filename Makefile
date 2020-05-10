NAME = syscall

CC=gcc
CFLAGS=-std=c99 -Wall -Wpedantic
PREFIX ?= /usr/local

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
	   getuid \
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
	   unlink \
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
	   unlink

all: tab $(NAME)
tab:
	echo -n > tab.h
	for s in $(SYSCALLS); do \
		echo "{ \"$$s\", SYS_$$s }," >> tab.h; \
	done
	echo '{ 0, 0},' >> tab.h

install: $(NAME)
	install -m 755 $< $(PREFIX)/bin/$(NAME)
	gzip -f -k $<.1
	install -m 644 $<.1.gz $(PREFIX)/share/man/man1/$<.1.gz

uninstall:
	rm $(PREFIX)/bin/$(NAME) $(PREFIX)/share/man/man1/$(NAME).1.gz

clean:
	-rm -f tab.h
	-rm -f $(NAME).o
	-rm -f $(NAME)
	-rm -f $(NAME).1.gz
