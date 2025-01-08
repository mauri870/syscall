#include <errno.h>
#include <getopt.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/random.h>
#include <unistd.h>

#include "syscalls_generated.c"

#define NARG 5

uintptr_t arg[NARG];
char buf[BUFSIZ];

uintptr_t parse(char *s);

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
      return 0;
    case 'h':
      fprintf(stderr, "usage: \tsyscall [-o -v -l] entry [args; "
                      "buf==1MB buffer]\n");
      fprintf(stderr, "\tsyscall write 1 hello 5\n");
      fprintf(stderr, "\tsyscall -o read 0 buf 5\n");
      fprintf(stderr, "\tsyscall -o getcwd buf 100\n");
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

  handle_syscall(arg);
  if (errno != 0) {
    fprintf(stderr, strerror(errno));
    return -1;
  }

  if (oflag)
    printf("%s", buf);
  if (vflag)
    fprintf(stderr, "Syscall return: %d\n", errno);
  return 0;
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
