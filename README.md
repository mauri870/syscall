# syscall - Test a system call

This is an effort to port the plan9 syscall command to Linux by using syscall(2). Not all the system calls are supposed to work since the system call convention on linux is more complex than plan9 but the most trivial ones are already implemented.

## Compilation

```bash
make
make install
```

## Usage:

```bash
syscall -h
man 1 syscall
```

## Examples

```bash
syscall write 1 Hello 5
syscall read 0 buf 5
syscall exit 2
syscall getpid
```
