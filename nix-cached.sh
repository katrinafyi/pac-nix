#!/bin/bash -ex

# if given command is fully cached, does nothing. otherwise, runs command.
set -o pipefail

if [[ "$1" == build ]]; then
  nix "$@" --dry-run  # ensure command would succeed

  if nix "$@" --dry-run 2>&1 | grep -q "will be built"; then
    exec nix "$@"
  else
    echo "$0: skipping cached build: $@"
  fi
else
  exec nix "$@"
fi
