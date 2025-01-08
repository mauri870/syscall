#!/bin/bash

INPUT_FILE="syscalls.txt"
OUTPUT_FILE="syscalls_generated.c"

cat << 'EOF' > "$OUTPUT_FILE"
// DO NOT EDIT. THIS IS AUTOMATICALLY GENERATED.
#define _GNU_SOURCE
#define _COSMO_SOURCE
#define _DEFAULT_SOURCE
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <time.h>
#include <sched.h>
#include <sys/utsname.h>

void handle_syscall(uintptr_t *arg) {
    int match = 0;

EOF

while IFS=, read -r sys_name args; do
    # ignore comments
    [[ "$sys_name" =~ ^#.*$ ]] && continue
    # trim trailing spaces
    echo $sys_name
    echo $args
    sys_name=$(echo "$sys_name" | xargs)
    args=$(echo "$args" | xargs)
    if [[ -n "$sys_name" ]]; then
        cat << EOF >> "$OUTPUT_FILE"
    if (strcmp((char *)arg[0], "$sys_name") == 0) {
        match = 1;
        $sys_name($args);
    }
EOF
    fi
done < "$INPUT_FILE"

cat << 'EOF' >> "$OUTPUT_FILE"
    if (!match) {
        fprintf(stderr, "Unknown syscall: %s\n", (char *)arg[0]);
        exit(1);
    }
}
EOF

echo "Generated $OUTPUT_FILE"