#!/usr/bin/env python3
# vim: ts=2 sts=2 et sw=2

import sys
import json
import pathlib
import argparse
import subprocess
import collections
import dataclasses 

@dataclasses.dataclass
class Repo:
  input: str = ''
  owner: str = ''
  repo: str = ''

  patched: str = ''
  patches: list[str] = dataclasses.field(default_factory=list)
  locked: dict = dataclasses.field(default_factory=dict)

def main(argv):
  argp = argparse.ArgumentParser('nix flake update with patches.')
  argp.add_argument('--flake', '-f', default=pathlib.Path('.'), type=pathlib.Path, 
                    help='path to directory of flake')
  argp.add_argument('--patched-suffix', default='-patched', type=str)
  argp.add_argument('--patch-suffix', default='-patch-', type=str)
  argp.add_argument('--print-inputs', action='store_true',
                    help='print flake inputs matching patched/patch suffixes, space-separated.')

  args = argp.parse_args(argv[1:])
  print(args)

  with open(args.flake / 'flake.lock') as f:
    lock = json.load(f)

  repos = collections.defaultdict(Repo)

  for k, v in lock['nodes'].items():
    orig = v.get('original')
    if not orig: continue # "root" object

    if k.endswith(args.patched_suffix):
      name = k[:len(k)-len(args.patched_suffix)]
      print(name ,'asd')

      repos[name].patched = k
    elif (split := k.rsplit(args.patch_suffix, 1)) and len(split) == 2:
      name, num = split
      try: num = int(num)
      except ValueError: num = None
      if num is not None:
        repos[name].patches.append(orig['url'])
    elif 'repo' in orig:
      repos[k].input = k
      repos[k].owner = orig['owner']
      repos[k].repo = orig['repo']
      repos[k].locked = v['locked']

  print(lock)
  print(repos)



if __name__ == '__main__':
  sys.exit(main(sys.argv))
