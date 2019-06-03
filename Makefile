NAME = syscall

PREFIX ?= /usr/local

SYSCALLS = exit \
	   write \
	   read \
	   getpid \
	   getcwd \
	   open \
	   close \
	   mkdir \
	   rmdir \
	   rename \
	   link \
	   chmod \
	   unlink \
	   symlink \
	   readlink \
	   getuid \
	   syslog

all: $(NAME)
$(NAME): tab $(NAME).o
	gcc $(NAME).o -o $(NAME)

$(NAME).o: $(NAME).c
	gcc $(DEBUG) -c $(NAME).c -o $(NAME).o

tab:
	echo -n > tab.h
	for s in $(SYSCALLS); do \
		echo "{ \"$$s\", SYS_$$s }," >> tab.h; \
	done

install: $(NAME)
	install -m 755 $< $(PREFIX)/bin/$(NAME)
	gzip -f -k $<.1
	install -m 644 $<.1.gz $(PREFIX)/share/man/man1/$<.1.gz

uninstall:
	rm $(PREFIX)/bin/$(NAME) $(PREFIX)/share/man/man1/$(NAME).1.gz

debug: DEBUG = -DDEBUG
debug: all

clean:
	-rm -f tab.h
	-rm -f $(NAME).o
	-rm -f $(NAME)
	-rm -f $(NAME).1.gz
