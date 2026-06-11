#!/bin/bash -ex

# if given command is fully cached, does nothing. otherwise, runs command.
set -o pipefail

if [[ "$1" == build ]]; then
  nix "$@" --dry-run  # ensure command would succeed

  out="$(nix "$@" --dry-run 2>&1)"

  if grep -q "will be built" <<< "$out"; then
    exec nix "$@"
  elif grep -q "will be fetched" <<< "$out"; then
    echo "$0: skipping cached build: $@"
  else
    echo "$0: ERROR: unknown outcome of --dry-run for $@" >&2
    exit 1
  fi
else
  exec nix "$@"
fi
