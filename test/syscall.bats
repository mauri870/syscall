#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

SYSCALL="$BATS_TEST_DIRNAME/../syscall"

# ---------------------------------------------------------------------------
# Argument handling
# ---------------------------------------------------------------------------

@test "no arguments prints error and exits non-zero" {
    run "$SYSCALL"
    [ "$status" -ne 0 ]
    [[ "$output" == *"No entry specified"* ]]
}

@test "unknown syscall name exits non-zero" {
    run "$SYSCALL" nosuchsyscall
    [ "$status" -ne 0 ]
    [[ "$output" == *"Invalid syscall entry"* ]]
}

# ---------------------------------------------------------------------------
# Flags
# ---------------------------------------------------------------------------

@test "-h exits 0 and prints usage" {
    run "$SYSCALL" -h
    [ "$status" -eq 0 ]
    [[ "$output" == *"usage"* ]]
}

@test "-l lists syscalls one per line" {
    run "$SYSCALL" -l
    [ "$status" -eq 0 ]
    [ "$(echo "$output" | wc -l)" -gt 1 ]
}

@test "-l output includes expected entries" {
    run "$SYSCALL" -l
    [ "$status" -eq 0 ]
    [[ "$output" == *"write"* ]]
    [[ "$output" == *"read"* ]]
    [[ "$output" == *"getpid"* ]]
    [[ "$output" == *"mmap"* ]]
}

@test "-v prints return value to stderr" {
    run --separate-stderr "$SYSCALL" -v getpid
    [ "$status" -eq 0 ]
    [[ "$stderr" =~ ^"Syscall return: "[0-9]+$ ]]
}

# ---------------------------------------------------------------------------
# Identity / process info  (no input and scalar return)
# ---------------------------------------------------------------------------

@test "getuid return value matches real uid" {
    run --separate-stderr "$SYSCALL" -v getuid
    [ "$status" -eq 0 ]
    [ "$stderr" = "Syscall return: $(id -u)" ]
}

@test "getgid return value matches real gid" {
    run --separate-stderr "$SYSCALL" -v getgid
    [ "$status" -eq 0 ]
    [ "$stderr" = "Syscall return: $(id -g)" ]
}

@test "geteuid return value matches effective uid" {
    run --separate-stderr "$SYSCALL" -v geteuid
    [ "$status" -eq 0 ]
    [ "$stderr" = "Syscall return: $(id -u)" ]
}

@test "getegid return value matches effective gid" {
    run --separate-stderr "$SYSCALL" -v getegid
    [ "$status" -eq 0 ]
    [ "$stderr" = "Syscall return: $(id -g)" ]
}

@test "getpgrp returns a positive number" {
    run --separate-stderr "$SYSCALL" -v getpgrp
    [ "$status" -eq 0 ]
    [[ "$stderr" =~ ^"Syscall return: "[0-9]+$ ]]
}

@test "getpid returns a positive number" {
    run --separate-stderr "$SYSCALL" -v getpid
    [ "$status" -eq 0 ]
    [[ "$stderr" =~ ^"Syscall return: "[0-9]+$ ]]
}

# ---------------------------------------------------------------------------
# getrandom
# ---------------------------------------------------------------------------

@test "getrandom returns requested byte count" {
    run --separate-stderr "$SYSCALL" -v getrandom buf 16 0
    [ "$status" -eq 0 ]
    [ "$stderr" = "Syscall return: 16" ]
}

@test "getrandom with GRND_RANDOM flag returns requested byte count" {
    run --separate-stderr "$SYSCALL" -v getrandom buf 16 1
    [ "$status" -eq 0 ]
    [ "$stderr" = "Syscall return: 16" ]
}

# ---------------------------------------------------------------------------
# Scalar input and scalar return
# ---------------------------------------------------------------------------

@test "alarm with 0 returns 0 when no previous alarm was set" {
    run --separate-stderr "$SYSCALL" -v alarm 0
    [ "$status" -eq 0 ]
    [ "$stderr" = "Syscall return: 0" ]
}

@test "dup duplicates a file descriptor" {
    # dup(1) must return a new fd >= 3
    run --separate-stderr "$SYSCALL" -v dup 1
    [ "$status" -eq 0 ]
    local fd="${stderr#Syscall return: }"
    [ "$fd" -ge 3 ]
}

@test "dup2 duplicates to a specific target fd" {
    run --separate-stderr "$SYSCALL" -v dup2 1 10
    [ "$status" -eq 0 ]
    [ "$stderr" = "Syscall return: 10" ]
}

@test "close on an invalid fd fails" {
    run "$SYSCALL" close 9999
    [ "$status" -ne 0 ]
}

@test "fcntl F_GETFD on stdout returns fd flags" {
    # F_GETFD = 1; returns 0 (no FD_CLOEXEC) or 1 (FD_CLOEXEC set)
    run --separate-stderr "$SYSCALL" -v fcntl 1 1 0
    [ "$status" -eq 0 ]
    [[ "$stderr" =~ ^"Syscall return: "[0-9]+$ ]]
}

@test "open returns a valid file descriptor" {
    run --separate-stderr "$SYSCALL" -v open /dev/null 0 0
    [ "$status" -eq 0 ]
    local fd="${stderr#Syscall return: }"
    [ "$fd" -ge 3 ]
}

@test "open on a nonexistent path fails" {
    run "$SYSCALL" open /no-such-file-$$ 0 0
    [ "$status" -ne 0 ]
}

# ---------------------------------------------------------------------------
# write, fd + string input
# ---------------------------------------------------------------------------

@test "write to stdout with numeric fd" {
    run "$SYSCALL" write 1 hello 5
    [ "$status" -eq 0 ]
    [ "$output" = "hello" ]
}

@test "write to stdout using stdout alias" {
    run "$SYSCALL" write stdout hello 5
    [ "$status" -eq 0 ]
    [ "$output" = "hello" ]
}

@test "write to stderr using stderr alias" {
    run --separate-stderr "$SYSCALL" write stderr oops 4
    [ "$status" -eq 0 ]
    [ "$stderr" = "oops" ]
}

# ---------------------------------------------------------------------------
# read, fd + buf and buffer output
# ---------------------------------------------------------------------------

@test "read using stdin alias fills buf" {
    run bash -c "echo -n hello | $SYSCALL -o read stdin buf 5"
    [ "$status" -eq 0 ]
    [ "$output" = "hello" ]
}

# ---------------------------------------------------------------------------
# Path and effect  (string input, side-effect output)
# ---------------------------------------------------------------------------

@test "access succeeds on existing path" {
    run "$SYSCALL" access / 0
    [ "$status" -eq 0 ]
}

@test "access fails on nonexistent path" {
    run "$SYSCALL" access /no-such-path-$$ 0
    [ "$status" -ne 0 ]
}

@test "mkdir creates a directory" {
    run "$SYSCALL" mkdir "$BATS_TEST_TMPDIR/newdir" 0755
    [ "$status" -eq 0 ]
    [ -d "$BATS_TEST_TMPDIR/newdir" ]
}

@test "mkdir on existing directory fails" {
    mkdir "$BATS_TEST_TMPDIR/existing"
    run "$SYSCALL" mkdir "$BATS_TEST_TMPDIR/existing" 0755
    [ "$status" -ne 0 ]
}

@test "rmdir removes a directory" {
    mkdir "$BATS_TEST_TMPDIR/toremove"
    run "$SYSCALL" rmdir "$BATS_TEST_TMPDIR/toremove"
    [ "$status" -eq 0 ]
    [ ! -d "$BATS_TEST_TMPDIR/toremove" ]
}

@test "rename moves a file" {
    local src="$BATS_TEST_TMPDIR/src"
    local dst="$BATS_TEST_TMPDIR/dst"
    touch "$src"
    run "$SYSCALL" rename "$src" "$dst"
    [ "$status" -eq 0 ]
    [ ! -e "$src" ]
    [ -e "$dst" ]
}

@test "link creates a hard link" {
    local src="$BATS_TEST_TMPDIR/original"
    local lnk="$BATS_TEST_TMPDIR/hardlink"
    touch "$src"
    run "$SYSCALL" link "$src" "$lnk"
    [ "$status" -eq 0 ]
    [ -e "$lnk" ]
}

@test "symlink creates a symbolic link" {
    local target="$BATS_TEST_TMPDIR/target"
    local lnk="$BATS_TEST_TMPDIR/symlink"
    touch "$target"
    run "$SYSCALL" symlink "$target" "$lnk"
    [ "$status" -eq 0 ]
    [ -L "$lnk" ]
}

@test "unlink removes a file" {
    local file="$BATS_TEST_TMPDIR/todelete"
    touch "$file"
    run "$SYSCALL" unlink "$file"
    [ "$status" -eq 0 ]
    [ ! -e "$file" ]
}

@test "chmod changes file permissions" {
    local file="$BATS_TEST_TMPDIR/permfile"
    touch "$file"
    run "$SYSCALL" chmod "$file" 0400
    [ "$status" -eq 0 ]
    [ "$(stat -c '%a' "$file")" = "400" ]
}

@test "truncate sets file to given size" {
    local file="$BATS_TEST_TMPDIR/truncfile"
    echo "hello world" > "$file"
    run "$SYSCALL" truncate "$file" 5
    [ "$status" -eq 0 ]
    [ "$(wc -c < "$file")" -eq 5 ]
}

@test "chdir to existing directory succeeds" {
    run "$SYSCALL" chdir /tmp
    [ "$status" -eq 0 ]
}

@test "chdir to nonexistent directory fails" {
    run "$SYSCALL" chdir /no-such-dir-$$
    [ "$status" -ne 0 ]
}

# ---------------------------------------------------------------------------
# Path and buf output  (string input, buffer filled)
# ---------------------------------------------------------------------------

@test "getcwd outputs an absolute path" {
    run "$SYSCALL" -o getcwd buf 100
    [ "$status" -eq 0 ]
    [[ "$output" == /* ]]
}

@test "readlink reads a symbolic link target" {
    local target="$BATS_TEST_TMPDIR/rltarget"
    local lnk="$BATS_TEST_TMPDIR/rllink"
    touch "$target"
    ln -s "$target" "$lnk"
    run "$SYSCALL" -o readlink "$lnk" buf 256
    [ "$status" -eq 0 ]
    [ "$output" = "$target" ]
}

@test "stat succeeds on an existing file" {
    run "$SYSCALL" stat /dev/null buf
    [ "$status" -eq 0 ]
}

@test "stat on a nonexistent file fails" {
    run "$SYSCALL" stat /no-such-file-$$ buf
    [ "$status" -ne 0 ]
}

@test "lstat succeeds on a symbolic link" {
    local target="$BATS_TEST_TMPDIR/lsttarget"
    local lnk="$BATS_TEST_TMPDIR/lstlink"
    touch "$target"
    ln -s "$target" "$lnk"
    run "$SYSCALL" lstat "$lnk" buf
    [ "$status" -eq 0 ]
}

@test "uname fills buf with non-empty content" {
    run "$SYSCALL" -o uname buf
    [ "$status" -eq 0 ]
    [ -n "$output" ]
}

@test "pipe succeeds" {
    run "$SYSCALL" pipe buf
    [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# fd operations via inherited file descriptors
# ---------------------------------------------------------------------------

@test "fstat on stdin succeeds" {
    run "$SYSCALL" fstat 0 buf
    [ "$status" -eq 0 ]
}

@test "lseek returns the new file offset" {
    local file="$BATS_TEST_TMPDIR/seekfile"
    echo -n "hello" > "$file"
    # SEEK_SET = 0; seek to offset 3
    run --separate-stderr bash -c "exec 3<'$file'; $SYSCALL -v lseek 3 3 0"
    [ "$status" -eq 0 ]
    [ "$stderr" = "Syscall return: 3" ]
}

@test "pwrite64 writes at offset" {
    local file="$BATS_TEST_TMPDIR/pwfile"
    dd if=/dev/zero bs=10 count=1 > "$file" 2>/dev/null
    run bash -c "exec 3<>'$file'; $SYSCALL pwrite64 3 hi 2 3"
    [ "$status" -eq 0 ]
}

@test "pread64 reads from offset" {
    local file="$BATS_TEST_TMPDIR/prfile"
    dd if=/dev/zero bs=10 count=1 > "$file" 2>/dev/null
    bash -c "exec 3<>'$file'; $SYSCALL pwrite64 3 hi 2 3"
    run bash -c "exec 3<'$file'; $SYSCALL -o pread64 3 buf 2 3"
    [ "$status" -eq 0 ]
    [ "$output" = "hi" ]
}

@test "ftruncate sets file size via fd" {
    local file="$BATS_TEST_TMPDIR/ftruncfile"
    echo "hello world" > "$file"
    run bash -c "exec 3<>'$file'; $SYSCALL ftruncate 3 5"
    [ "$status" -eq 0 ]
    [ "$(wc -c < "$file")" -eq 5 ]
}

@test "fchmod changes file permissions via fd" {
    local file="$BATS_TEST_TMPDIR/fchmodfile"
    touch "$file"
    run bash -c "exec 3<>'$file'; $SYSCALL fchmod 3 0400"
    [ "$status" -eq 0 ]
    [ "$(stat -c '%a' "$file")" = "400" ]
}

@test "fsync on a regular file succeeds" {
    local file="$BATS_TEST_TMPDIR/fsyncfile"
    touch "$file"
    run bash -c "exec 3>'$file'; $SYSCALL fsync 3"
    [ "$status" -eq 0 ]
}

@test "fdatasync on a regular file succeeds" {
    local file="$BATS_TEST_TMPDIR/fdatafile"
    touch "$file"
    run bash -c "exec 3>'$file'; $SYSCALL fdatasync 3"
    [ "$status" -eq 0 ]
}

@test "flock acquires an exclusive lock" {
    local file="$BATS_TEST_TMPDIR/flockfile"
    touch "$file"
    # LOCK_EX = 2
    run bash -c "exec 3<>'$file'; $SYSCALL flock 3 2"
    [ "$status" -eq 0 ]
}

@test "fchdir changes directory via fd" {
    run bash -c "exec 3</tmp; $SYSCALL fchdir 3"
    [ "$status" -eq 0 ]
}
