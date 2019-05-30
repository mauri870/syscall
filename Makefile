NAME = syscall

SYSCALLS = exit \
	   write \
	   read \
	   getpid \
	   fstat \
	   close

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

debug: DEBUG = -DDEBUG
debug: all

clean:
	-rm -f tab.h
	-rm -f $(NAME).o
	-rm -f $(NAME)
