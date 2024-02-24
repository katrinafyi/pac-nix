#!/usr/bin/env python3
# vim: ts=2 sts=2 et sw=2

# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "PyGithub~=2.2.0",
# ]
# ///

import github

import os
import sys
import json
import argparse
import tempfile
import subprocess
import collections
import dataclasses

from pathlib import Path
from typing import Iterable


@dataclasses.dataclass
class Repo:
  input: str = ''
  owner: str = ''
  repo: str = ''

  patched: str = ''
  patches: list[tuple[tuple, str, Path]] = dataclasses.field(default_factory=list)
  locked: dict = dataclasses.field(default_factory=dict)

def segment_patches(tmp: Path, num: int, url: str, path: Path) -> Iterable[tuple[tuple, str, Path]]:
  with open(path, 'rb') as f:
    patches = f.read()
  chunks = patches.split(b'\n\nFrom ')
  count = len(chunks)
  for i, c in enumerate(b'From ' + c for c in chunks):
    pth = tmp / f'{num}-{i}-{path.name}.patch'
    with open(pth, 'wb') as f:
      f.write(c)
      f.write(b'\n\n')
    yield ((num, i), url, pth)


def main(argv):
  argp = argparse.ArgumentParser('nix flake update with patches.')
  argp.add_argument('--flake', '-f', default=Path('.'), type=Path, 
                    help='path to directory of flake')
  argp.add_argument('--patched-suffix', default='-patched', type=str)
  argp.add_argument('--patch-suffix', default='-patch-', type=str)
  argp.add_argument('--print-inputs', action='store_true',
                    help='print flake inputs matching patched/patch suffixes, space-separated.')
  argp.add_argument('--tmp', default=tempfile.gettempdir())

  args = argp.parse_args(argv[1:])
  args.tmp = Path(tempfile.mkdtemp(dir=args.tmp))
  print(args)

  args.flake = args.flake.absolute()
  with open(args.flake / 'flake.lock') as f:
    lock = json.load(f)

  repos = collections.defaultdict(Repo)

  for k, v in lock['nodes'].items():
    orig = v.get('original')
    if not orig: continue # "root" object

    if k.endswith(args.patched_suffix):
      name = k[:len(k)-len(args.patched_suffix)]

      repos[name].patched = k
    elif (split := k.rsplit(args.patch_suffix, 1)) and len(split) == 2:
      name, num = split
      try: num = int(num)
      except ValueError: num = None
      if num is not None:
        # nix eval --impure --expr "(builtins.getFlake \"$(realpath .)\").inputs.nixpkgs.sourceInfo.outPath"
        path = subprocess.check_output(
          ['nix', 'eval', '--impure', '--expr',
           f'(builtins.getFlake "{args.flake}").inputs.{k}.outPath'])
        path = json.loads(path)
        path = Path(path)

        segmented = segment_patches(args.tmp, num, orig['url'], path)
        repos[name].patches.extend(segmented)
        # repos[name].patches.append(((num, ), orig['url'], path))
    elif 'repo' in orig:
      repos[k].input = k
      repos[k].owner = orig['owner']
      repos[k].repo = orig['repo']
      repos[k].locked = v['locked']

  # XXX need to iterate over patched repos
  repo = next(iter(repos.values()))
  rev = repo.locked['rev']
  repo.patches.sort(key=lambda x: x[0])
  patches = [p[2] for p in repo.patches]
  print(patches)
  for p in patches:
    print('patching', p, '...')
    a = subprocess.check_output(
        ['/home/rina/go/bin/patch2pr',
         # '-repository', 'NixOS/nixpkgs',
         # '-fork', '-fork-repository', 'katrinafyi/nixpkgs',
         '-repository', 'katrinafyi/nixpkgs',
         '-patch-base', rev, 
         '-no-pull-request', '-force',
         '-json', p]
        )
    print(a.decode('ascii'))
    rev = json.loads(a)['commit']

  # print(lock)
  print(repos)

if __name__ == '__main__':
  sys.exit(main(sys.argv))
