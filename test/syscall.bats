#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

SYSCALL="$BATS_TEST_DIRNAME/../syscall"

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

@test "-h exits 0 and prints usage" {
    run "$SYSCALL" -h
    [ "$status" -eq 0 ]
    [[ "$output" == *"usage"* ]]
}

@test "-l lists syscalls one per line" {
    run "$SYSCALL" -l
    [ "$status" -eq 0 ]
    # output must contain multiple lines
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
    [[ "$stderr" == "Syscall return: "* ]]
    [[ "$stderr" =~ ^"Syscall return: "[0-9]+$ ]]
}

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

@test "-o read using stdin alias outputs buffer contents" {
    run bash -c "echo -n hello | $SYSCALL -o read stdin buf 5"
    [ "$status" -eq 0 ]
    [ "$output" = "hello" ]
}

@test "-o getcwd outputs an absolute path" {
    run "$SYSCALL" -o getcwd buf 100
    [ "$status" -eq 0 ]
    [[ "$output" == /* ]]
}

@test "getuid return value matches current uid" {
    run --separate-stderr "$SYSCALL" -v getuid
    [ "$status" -eq 0 ]
    [ "$stderr" = "Syscall return: $(id -u)" ]
}

@test "getgid return value matches current gid" {
    run --separate-stderr "$SYSCALL" -v getgid
    [ "$status" -eq 0 ]
    [ "$stderr" = "Syscall return: $(id -g)" ]
}

@test "mkdir creates a directory" {
    run "$SYSCALL" mkdir "$BATS_TEST_TMPDIR/newdir" 0755
    [ "$status" -eq 0 ]
    [ -d "$BATS_TEST_TMPDIR/newdir" ]
}

@test "failed syscall exits non-zero" {
    mkdir "$BATS_TEST_TMPDIR/existing"
    run "$SYSCALL" mkdir "$BATS_TEST_TMPDIR/existing" 0755
    [ "$status" -ne 0 ]
}
