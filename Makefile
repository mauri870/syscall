NAME = syscall

SYSCALLS = exit \
	   write \
	   read \
	   getpid \
	   fstat

all: $(NAME)
$(NAME): tab $(NAME).o
	gcc $(NAME).o -o $(NAME)

$(NAME).o: $(NAME).c
	gcc $(DEBUG) -c $(NAME).c -o $(NAME).o

tab:
	for s in $(SYSCALLS); do \
		echo "{ \"$$s\", (int(*)())$$s }," >> tab.tmp; \
	done
	mv tab.tmp tab.h

debug: DEBUG = -DDEBUG
debug: all

clean:
	-rm -f tab.h
	-rm -f $(NAME).o
	-rm -f $(NAME)
