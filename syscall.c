#define _GNU_SOURCE
#include <errno.h>
#include <getopt.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/syscall.h>
#include <unistd.h>

#include "syscall.h"

#define NARG 5

uintptr_t arg[NARG];
char buf[BUFSIZ];

const syscall_table_t syscall_table = {
#include "tab.h"
};

int main(int argc, char **argv) {
	int oflag = 0, vflag = 0, opt;
	while ((opt = getopt(argc, argv, "ovlh")) != -1) {
		switch (opt) {
			case 'o':
				oflag = 1;
				break;
			case 'v':
				vflag = 1;
				break;
			case 'l':
				for (int i = 0; syscall_table[i].name; i++) {
					fprintf(stdout, "%s ", syscall_table[i].name);
				}
				return 0;
			case 'h':
				fprintf(stderr,
					"usage: \tsyscall [-o -v -l] entry [args; "
					"buf==1MB buffer]\n");
				fprintf(stderr, "\tsyscall write 1 hello 5\n");
				fprintf(stderr, "\tsyscall -o read 0 buf 5\n");
				fprintf(stderr,
					"\tsyscall -o getcwd buf 100\n");
			default:
				return -1;
		}
	}

	if (optind >= argc) {
		fprintf(stderr, "No entry specified\n");
		return -1;
	}

	for (int i = 0; i < argc - optind; i++) {
		arg[i] = parse(argv[i + optind]);
	}

	for (int i = 0; syscall_table[i].name; i++) {
		if (strcmp(syscall_table[i].name, (char *)arg[0]) == 0) {
			int rc = syscall(syscall_table[i].code, arg[1], arg[2],
					 arg[3], arg[4]);
			if (rc == -1) {
				perror("syscall");
			}

			if (oflag) printf("%s", buf);
			if (vflag) fprintf(stderr, "Syscall return: %d\n", rc);
			return 0;
		}
	}
	fprintf(stderr, "Invalid syscall entry: %s\n", (char *)arg[0]);
	return -1;
}

uintptr_t parse(char *s) {
	char *t;
	uintptr_t l;

	if (strcmp(s, "buf") == 0) {
		return (uintptr_t)buf;
	}

	l = strtoull(s, &t, 0);
	if (t > s && *t == 0) {
		return (uintptr_t)l;
	}

	return (uintptr_t)s;
}
