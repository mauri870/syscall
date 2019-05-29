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

// TODO: Generate this table at compile time by parsing unistd.h or something
const syscall_table_t syscall_table = {
	{ "exit", 60 },
	{ "write", 1 },
	{ "read", 0 },
	{ "getpid", 39 },
	{ 0, 0 }
};

int main(int argc, char **argv) {
	if (argc < 2) return 1;

	for (int i = 1; i < argc; i++) {
		arg[i - 1] = parse(argv[i]);
	}

	for (int i = 0; syscall_table[i].name; i++) {
		if (strcmp(syscall_table[i].name, argv[1]) == 0) {
	 		int r  = syscall(syscall_table[i].code, arg[1], arg[2], arg[3], arg[4]);
			if (r == -1) {
				fprintf(stderr, "Error %d: %s\n", errno, strerror(errno));
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