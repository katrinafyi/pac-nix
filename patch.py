#!/usr/bin/env python3
# vim: ts=2 sts=2 et sw=2

# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "PyGithub~=2.2.0",
# ]
# ///

import github

from github.GitTreeElement import GitTreeElement

import os
import base64
import shutil
import tempfile
import subprocess

from pathlib import Path


# using an access token
auth = github.Auth.Token(os.environ['GITHUB_TOKEN'])

# First create a Github instance:

# Public Web Github
g = github.Github(auth=auth)

print(g)

repo = g.get_repo('katrinafyi/nixpkgs')
# branch = repo.get_branch('master').commit
branch = repo.get_commit('ffacc011dffba16ca360028d1f81cae99ff1280f')
print(branch)
treesha = (branch.commit.tree)
treebase = repo.get_git_tree(treesha.sha, recursive=True)

paths = {}
for x in treebase.tree:
  paths[Path(x.path)] = x
# print(paths)


import sys
with open(sys.argv[1], 'rb') as f:
  patch = f.read()

import shlex
before: set[Path] = set()
after: set[Path] = set()
for l in patch.splitlines():
  if l.startswith(b'diff --git '):
    # XXX may break if \ escapes appear in paths (?!)
    diff, dashdashgit, a, b = shlex.split(l.decode('ascii'))
    before.add(Path(a).relative_to('a'))
    after.add(Path(b).relative_to('b'))

d = Path(tempfile.mkdtemp())
# print(before, after)

os.chdir(d)
for p in before:
  os.makedirs(p.parent, exist_ok=True)
  pth: GitTreeElement = paths[p]
  data = repo.get_git_blob(pth.sha)
  data = base64.b64decode(data.content)
  if pth.mode in ('100644', '100755'):
    with open(p, 'wb') as f:
      f.write(data)
    mode = int(pth.mode[-3:], 8)
    p.chmod(mode)
  elif pth.mode == '120000':
    p.symlink_to(data)
  elif pth.mode == '160000':
    assert False, f'path kind submodule unsupported: {p}'
  elif pth.mode == '040000':
    assert False, f'path kind subdirectory unsupported: {p}'
  print(p, pth)

print()
print(d)
print()

# XXX log original path of patch
subprocess.run(['patch', '-t', '-p1'], input=patch, check=True)

treenew = []
for f in after:
  if f.is_symlink():
    data = str(f.readlink()).encode('utf-8')
    mode = '120000'
  else:
    with open(f, 'rb') as file: data = file.read()
    mode = '100' + oct(f.stat().st_mode)[-3:]

  data = base64.b64encode(data).decode('ascii')

  blob = repo.create_git_blob(data, encoding='base64')
  item = github.InputGitTreeElement(
      str(f), mode, type='blob', sha=blob.sha)
  treenew.append(item)

new = repo.create_git_tree(treenew, base_tree=treebase)
print(new)

print(repo.create_git_commit('asdf', new, [branch.commit]))









