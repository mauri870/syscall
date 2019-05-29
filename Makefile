NAME = syscall

all: $(NAME)
$(NAME): $(NAME).o
	gcc $(NAME).o -o $(NAME)

$(NAME).o: $(NAME).c
	gcc $(DEBUG) -c $(NAME).c -o $(NAME).o

debug: DEBUG = -DDEBUG
debug: all

clean:
	-rm -f $(NAME).o
	-rm -f $(NAME)
