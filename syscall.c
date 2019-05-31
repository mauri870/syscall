#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/syscall.h>

#include "debug.h"
#include "syscall.h"

#define BUF_SIZE 1048576
#define NARG 5

uintptr_t arg[NARG];
char *buf[BUF_SIZE];

const syscall_table_t syscall_table = {
	#include "tab.h"
	{ 0, 0 }
};

int main(int argc, char **argv) {
	int oflag;
	int opt;
	while ((opt = getopt(argc, argv, "oh")) != -1) {
		switch (opt) {
			case 'o':
				oflag = 1;
				break;
			case 'h':
				fprintf(stderr, "usage: \tsyscall [-o] entry [args; buf==1MB buffer]\n");
				fprintf(stderr, "\tsyscall write 1 hello 5\n");
				fprintf(stderr, "\tsyscall -o read 0 buf 5\n");
				fprintf(stderr, "\tsyscall -o getcwd buf 100\n");
			default:
				exit(EXIT_FAILURE);
		}
	}

	if (optind >= argc) {
		fprintf(stderr, "No entry specified\n");
		exit(EXIT_FAILURE);
	}

	for (int i = 0; i < argc - optind; i++) {
		arg[i] = parse(argv[i + optind]);
	}

	for (int i = 0; syscall_table[i].name; i++) {
		if (strcmp(syscall_table[i].name, (char *) arg[0]) == 0) {
	 		int r  = syscall(syscall_table[i].code, arg[1], arg[2], arg[3], arg[4]);
			if (r == -1) {
				fprintf(stderr, "Error %d: %s\n", errno, strerror(errno));
			} else {
				if (oflag) printf("%s", buf);
			}

			fprintf(stderr, "Syscall return: %d\n", r);

		}
	}

	return 0;	
}


uintptr_t parse(char *s) {
	char *t;
	uintptr_t l;
	
	if (strcmp(s, "buf") == 0) {
		return (uintptr_t) buf;
	}

	l = strtoull(s, &t, 0);
	if (t > s && *t == 0) {
		return l;
	}

	return (uintptr_t) s;
}
