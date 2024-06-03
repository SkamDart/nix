#!/usr/bin/env bash

source common.sh

clearStore

rm -rf "$TEST_ROOT"/case

opts="--option use-case-hack true"

# Check whether restoring and dumping a NAR that contains case
# collisions is round-tripping, even on a case-insensitive system.

# shellcheck disable=2086
# putting quotes around "$opts" causes the test to fail with
# 'unknown flag' on nix-store command because it is quoted
nix-store $opts  --restore "$TEST_ROOT/case" < case.nar
# shellcheck disable=2086
nix-store $opts --dump "$TEST_ROOT/case" > "$TEST_ROOT/case.nar"
cmp case.nar "$TEST_ROOT/case.nar"
# shellcheck disable=2086
[ "$(nix-hash $opts --type sha256 $TEST_ROOT/case)" = "$(nix-hash --flat --type sha256 case.nar)" ]

# Check whether we detect true collisions (e.g. those remaining after
# removal of the suffix).
touch "$TEST_ROOT/case/xt_CONNMARK.h~nix~case~hack~3"
# shellcheck disable=2086
(! nix-store $opts --dump $TEST_ROOT/case > /dev/null)
