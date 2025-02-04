#!/usr/bin/env python3

# vim: ts=2 sts=2 sw=2 et

# updates the revision hash for each upstream package.
# for each updated package, this checks the derivation can be built
# then commits its results.

# usage in flake:
# nix run .#update -- ARGS

import os
import string
import json
import logging
import argparse
import subprocess
import urllib.request

from typing import cast, Literal
from dataclasses import dataclass, field, fields

log = logging.getLogger()

@dataclass
class Package:
  attr: str
  repo: str  # github owner/repository
  branch: str = ''
  then: list[str] = field(default_factory=list) # users of this package, used for testing dependent builds.

  def repo_api(self) -> str:
    return f"https://api.github.com/repos/{self.repo}"

  def commits_api(self) -> str:
    assert self.branch
    return f"https://api.github.com/repos/{self.repo}/commits/{self.branch}"

  def compare_api(self, base: str) -> str:
    return f"https://api.github.com/repos/{self.repo}/compare/{base}...{self.branch}"

  def commits_atom(self) -> str:
    return f"https://github.com/{self.repo}/commits/{self.branch}.atom"

  def compare_link(self, base: str) -> str:
    return self.compare_permalink(base, self.branch)

  def compare_permalink(self, base: str, target: str) -> str:
    return f"https://github.com/{self.repo}/compare/{base}...{target}"

  def repo_git(self) -> str:
    return f'https://github.com/{self.repo}.git'

  def fetch_default_branch(self) -> str:
    out = run(['git', 'ls-remote', '--symref', self.repo_git(), 'HEAD'],
        stdout=subprocess.PIPE).stdout.decode('utf-8')
    return out.split('\t')[0].split('/')[-1]

  def fetch_commits_behind(self, base: str) -> int:
    return (
      curl_raw(self.compare_link(base) + '.patch')
      .replace('\r', '')
      .count('\n---\n')
    )

  def fetch_latest_commit(self) -> str:
    out = curl_raw(self.commits_atom())
    # <entry>
    #   <id>tag:github.com,2008:Grit::Commit/4fb69f108427b6b78ad9ee98744364eabf4b2178</id>
    #   <link type="text/html" rel="alternate" href="https://github.com/UQ-PAC/BASIL/commit/4fb69f108427b6b78ad9ee98744364eabf4b2178"/>
    left = 0
    left = out.find('<entry>', left)
    left = out.find('<link type="text/html"', left)
    left = out.find('github.com', left)
    right = out.find('"/>', left)
    commit = out[right-40:right]
    assert all(c in string.hexdigits for c in commit)
    return commit

@dataclass
class Args:
  mode: Literal['check', 'upgrade']
  dir: str
  rest: list[str]

PACKAGES: list[Package] = [
  Package('asli', 'UQ-PAC/aslp', then=[]), # aslp
  Package('bap-asli-plugin', 'UQ-PAC/bap-asli-plugin', then=[]), # bap-aslp
  Package('basil', 'UQ-PAC/bil-to-boogie-translator'),
  Package('bap-primus', 'UQ-PAC/bap', 'aarch64-pull-request-2'),
  Package('asl-translator', 'UQ-PAC/llvm-translator', 'main'),
  Package('gtirb-semantics', 'UQ-PAC/gtirb-semantics', 'main'),
  Package('alive2-aslp', 'katrinafyi/alive2', 'aslp'),
  Package('alive2-regehr', 'regehr/alive2', 'arm-tv'),
  Package('aslp_web', 'katrinafyi/aslp-web', 'main'),
  Package('compiler-explorer', 'ailrst/compiler-explorer', 'main'),
  Package('aslp-server', 'UQ-PAC/aslp-rpc'),
  Package('aslp-cpp', 'UQ-PAC/aslp-rpc'),
  Package('aslp_client_server_ocaml', 'UQ-PAC/aslp-rpc'),
]
# NOTE: also change files in ./.github/workflows/*.yml


def run(args: list[str], check: bool = True, **kwargs) -> subprocess.CompletedProcess:
  log.debug('subprocess: %s', str(args))
  return subprocess.run(args, check=check, **kwargs)


def curl_raw(url) -> str:
  req = urllib.request.Request(url)
  token = os.getenv('GITHUB_TOKEN')
  if token:
    req.add_header('Authorization', 'Bearer ' + token)
  log.debug('request: %s authenticated=%s', req.get_full_url(), bool(token))
  with urllib.request.urlopen(req) as f:
    return f.read().decode('utf-8')

def curl(url: str) -> dict:
  return json.loads(curl_raw(url))

def arg_path_exists(p: str) -> str:
  if not os.path.exists(p):
    try: open(p)
    except FileNotFoundError as e:
      raise argparse.ArgumentTypeError(e)
  return p

def try_remove(x: list, v):
  if v in x: x.remove(v)

def upgrade(p: Package, args: Args):
  flakeattr = f'{args.dir}#{p.attr}'
  broken = json.loads(run(
    ['nix', 'eval', '--json', f'{args.dir}#{p.attr}.meta.broken'],
    stdout=subprocess.PIPE, text=True).stdout)
  has_tests = 0 == run(
    ['nix', 'eval', '--json', f'{args.dir}#{p.attr}.tests'],
    check=False).returncode

  if not has_tests:
    try_remove(args.rest, '--test')

  if args.mode == 'upgrade':
    if broken:
      print(f'::warning title={p.attr} broken::will not build or test {p.attr} during upgrade')
      try_remove(args.rest, '--build')
      try_remove(args.rest, '--test')

    run(['nix-update', '--flake', '-f', args.dir, p.attr, '--version', f'branch={p.branch}'] +
        args.rest)
    for p2 in p.then:
      print(f'testing downstream build of {p2}...')
      run(['nix', 'build', f'{args.dir}#{p2}', '--no-out-link'])

  elif args.mode == 'check':

    current = run(['nix', 'eval', flakeattr + '.src.rev'],
                  stdout=subprocess.PIPE).stdout.decode('ascii').strip('"\n')

    total_commits = p.fetch_commits_behind(current)
    latest = p.fetch_latest_commit()
    permalink = p.compare_permalink(current, latest)

    print()
    print('compare link:', p.compare_link(current))
    if total_commits != 0:
      print(
        f"::warning title=package outdated: {p.attr}::"
        f"{p.attr} differs by {total_commits} non-merge commits from {p.branch} ({permalink})"
      )
    else:
      print(
        f"::notice title=package up to date: {p.attr}::"
        f"{p.attr} differs by {total_commits} non-merge commits from {p.branch} ({permalink})"
      )
    print()

  else:
    assert False


if __name__ == "__main__":
  logging.basicConfig(format='[%(levelname)s:%(name)s@%(filename)s:%(funcName)s:%(lineno)d] %(message)s')
  log.setLevel(logging.DEBUG)

  attrs = [x.attr for x in PACKAGES]
  p = argparse.ArgumentParser(description=f'updates pac-nix packages. supported packages: {", ".join(attrs)}.')
  p.add_argument('mode', choices=['check', 'upgrade', 'do-upgrade'],
                 help='action to perform. do-upgrade is upgrade but also builds, tests, and commits the changes.')
  p.add_argument('--dir', '-d', default='.', type=arg_path_exists,
                 help='use the given path as a flake.')
  p.add_argument('--attr', '-A', action='append', choices=attrs, default=[], metavar='PACKAGE', dest='attrs',
                 help='only act on the given packages.')
  p.add_argument('rest', nargs='*', metavar='-- NIX-UPDATE OPTIONS',
                 help='arguments to forward to nix-update.')

  args = p.parse_intermixed_args()
  log.debug('args=%s', str(args))

  if not args.attrs:
    args.attrs = attrs

  log.info('we will %s the following packages: %s', args.mode.upper(), str(args.attrs))
  PACKAGES = [p for p in PACKAGES if p.attr in args.attrs]

  if args.mode == 'do-upgrade':
    args.mode = 'upgrade'
    args.rest = ['--build', '--commit', '--test'] + args.rest

  for f in fields(Args):
    assert f.name in args, f.name

  for p in PACKAGES:
    if not p.branch:
      p.branch = p.fetch_default_branch()
      log.debug('inferred %s branch to be %s', p.repo, repr(p.branch))

  for p in PACKAGES:
    upgrade(p, cast(Args, args))

