#!/usr/bin/env python3
# vim: ts=2 sts=2 sw=2 et

import sys
import functools
import subprocess
from pathlib import Path
from typing import cast

@functools.cache
def nix_store_path():
  return Path('/nix/store')

@functools.cache
def nix_store_contents():
  return {
    f.name.split('-', 1)[0].encode('ascii'): f
    for f in nix_store_path().iterdir()
  }

@functools.cache
def compute_direct_deps(p: Path) -> set[Path]:
  # omits: e o t u
  # NOTE: deviates from nix's algorithm because we also look for / and -.
  # this speeds things up a fair bit, as it reduces spurious matches.
  proc = subprocess.run([
    'grep', '-r', r'/[0-9a-df-np-sv-z]\{32\}-',
    '--text', '--only-matching', '--no-filename',
    p
  ], stdout=subprocess.PIPE)

  # XXX: might see permission denied errors
  # assert proc.returncode in (0, 1)

  referenced_hashes = (x[1:-1] for x in proc.stdout.rstrip().split(b'\n'))


  # also find all symbolic link targets amongst the files
  find = subprocess.run([
    'find', p, '-type', 'l', '-printf', '%l\n'
  ], stdout=subprocess.PIPE)

  assert find.returncode == 0

  link_targets = (Path(x.decode('utf-8')) for x in find.stdout.rstrip().split(b'\n') if x)
  linked_store_paths = (Path(*p.parts[:4]) for p in link_targets if p.is_relative_to(nix_store_path()))
  # HACK: slice the first 4 parts to get only the /nix/store/HASH-NAME and drop the rest

  result = {
    nix_store_contents().get(h, None)
    for h in referenced_hashes
  }
  result.discard(None)

  result = cast(set[Path], result)

  result.update(linked_store_paths)

  return result

def compute_recursive_deps(p: set[Path]):
  deps = set(p)

  new_deps = set(deps)
  while new_deps:
    new_deps = { d for new_dep in new_deps for d in compute_direct_deps(new_dep) if d not in deps }

    deps.update(new_deps)

  return deps

def main(argv: list[str]):
  for x in sorted(compute_recursive_deps({ Path(x) for x in argv[1:] })):
    print(str(x))

if __name__ == "__main__":
  main(sys.argv)
