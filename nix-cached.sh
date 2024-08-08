#!/bin/bash

# if given command is fully cached, does nothing. otherwise, runs command.

if [[ "$1" == build ]] && nix "$@" --dry-run 2>&1 | tee /dev/stderr | grep -q "will be built"; then
  nix "$@"
fi
