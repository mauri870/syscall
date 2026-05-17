# syscall - Test a Linux system call

A port of the [Plan 9 syscall command](https://plan9.io/magic/man2html/1/syscall) to Linux. Rather than going through libc, it calls `syscall(2)` directly, which makes it useful for testing kernel behaviour, understanding how system calls work, and quick scripting without writing C.

Not every Linux syscall is invocable this way — some require kernel structures that can't be expressed as plain scalars — but the most common ones work fine.

## Build

```sh
make
make test
make install
make uninstall
```

## Usage

```
syscall [-o -v -l -h] entry [arg ...]
```

| Flag | Effect |
|------|--------|
| `-o` | Print the contents of `buf` to stdout after the call |
| `-v` | Print the syscall return value to stderr |
| `-l` | List all available syscalls and exit |
| `-h` | Print usage and exit |

### Special arguments

| Token | Expands to |
|-------|-----------|
| `buf` | An 8 KB scratch buffer, passed as a pointer |
| `stdin` | File descriptor 0 |
| `stdout` | File descriptor 1 |
| `stderr` | File descriptor 2 |

Up to 6 arguments can be passed, matching the maximum number of arguments any Linux syscall takes.

## Examples

Write a string to standard output:

```sh
syscall write stdout hello 5
```

Read 5 bytes from stdin and print the buffer:

```sh
echo -n hello | syscall -o read stdin buf 5
```

Get the current working directory:

```sh
syscall -ov getcwd buf 100
```

Get the PID of the current process:

```sh
syscall -v getpid
```

Get 16 bytes of random data from the kernel (1 == `GRND_RANDOM`):

```sh
syscall -ov getrandom buf 16 1
```

Create a directory:

```sh
syscall mkdir my-dir 0755
```

Rename a file:

```sh
syscall rename old-name new-name
```

Exit with a specific status code:

```sh
syscall exit 2
```

List all available syscalls:

```sh
syscall -l
```
