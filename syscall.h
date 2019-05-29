#ifndef SYSCALL_H
#define SYSCALL_H

#include <stdint.h>

typedef struct {
	char *name;
	int code;
} syscall_lookup_t;

typedef syscall_lookup_t syscall_table_t[];

uintptr_t parse(char *s);

#endif
