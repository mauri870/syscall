# syscall - Test a system call

This is an effort to port the plan9 syscall command to Linux. Not all the system calls are supposed to work since the system call convention on linux is more complex than plan9 but the most trivial ones are already implemented.
Instead of relying on the libc implementation this program uses the syscall(2) library function to invoke system calls.

## Compilation

```bash
make
make install
```

## Usage:

```bash
man 1 syscall
syscall -h
```

## Examples

```bash
syscall write 1 Hello 5
syscall -o read 0 buf 5
syscall exit 2
syscall getpid
syscall -o getcwd buf 100
```
