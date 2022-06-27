#!/bin/bash
set -euxo pipefail
IFS=$'\n\t'
cd "$(dirname "$0")"/..

export RUSTFLAGS="${RUSTFLAGS:-} -Z randomize-layout"

# -Zmiri-ignore-leaks is needed because we use detached threads in tests/docs: https://github.com/rust-lang/miri/issues/1371
MIRIFLAGS="-Zmiri-strict-provenance -Zmiri-symbolic-alignment-check -Zmiri-disable-isolation -Zmiri-ignore-leaks" \
    cargo miri test \
    -p crossbeam-queue \
    -p crossbeam-utils

# -Zmiri-ignore-leaks is needed because we use detached threads in tests/docs: https://github.com/rust-lang/miri/issues/1371
MIRIFLAGS="-Zmiri-strict-provenance -Zmiri-symbolic-alignment-check -Zmiri-disable-isolation -Zmiri-ignore-leaks" \
    cargo miri test \
    -p crossbeam-channel

# -Zmiri-ignore-leaks is needed for https://github.com/crossbeam-rs/crossbeam/issues/579
# -Zmiri-disable-stacked-borrows is needed for https://github.com/crossbeam-rs/crossbeam/issues/545
MIRIFLAGS="-Zmiri-symbolic-alignment-check -Zmiri-disable-isolation -Zmiri-disable-stacked-borrows -Zmiri-ignore-leaks" \
    cargo miri test \
    -p crossbeam-epoch \
    -p crossbeam-skiplist

# -Zmiri-ignore-leaks is needed for https://github.com/crossbeam-rs/crossbeam/issues/579
# -Zmiri-disable-stacked-borrows is needed for https://github.com/crossbeam-rs/crossbeam/issues/545
# -Zmiri-compare-exchange-weak-failure-rate=0.0 is needed because some sequential tests (e.g.,
# doctest of Stealer::steal) incorrectly assume that sequential weak CAS will never fail.
# -Zmiri-preemption-rate=0 is needed because this code technically has UB and Miri catches that.
MIRIFLAGS="-Zmiri-symbolic-alignment-check -Zmiri-disable-stacked-borrows -Zmiri-ignore-leaks -Zmiri-compare-exchange-weak-failure-rate=0.0 -Zmiri-preemption-rate=0" \
    cargo miri test \
    -p crossbeam-deque

# -Zmiri-ignore-leaks is needed for https://github.com/crossbeam-rs/crossbeam/issues/579
MIRIFLAGS="-Zmiri-symbolic-alignment-check -Zmiri-ignore-leaks" \
    cargo miri test \
    -p crossbeam
