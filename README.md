# pac-nix

[![build Nix packages](https://github.com/katrinafyi/pac-nix/actions/workflows/main.yml/badge.svg)](https://github.com/katrinafyi/pac-nix/actions/workflows/main.yml)
[![update Nix packages](https://github.com/katrinafyi/pac-nix/actions/workflows/update.yml/badge.svg)](https://github.com/katrinafyi/pac-nix/actions/workflows/update.yml)

An experiment to package [PAC](https://github.com/UQ-PAC)'s
tools with the Nix package manager.

This repository contains fixed-output derivations which fetch
and build a fixed version of each tool and its dependencies.
Nix's declarative nature makes this fast and reliable, 
independent of particular distributions or their package repository quirks.
Further, since each dependency is itself a static derivation, these can be cached.
z3 and BAP, which previously took dozens of minutes each,
are fetched in seconds.

Overall, Nix is an effective tool and well-suited to this task
of a consistent meta-build and dependency manager system.

## structure

The **pkgs.nix** file defines the package set as 
the usual \<nixpkgs\> extended with those from this repo.

For users of tools, the main packages are:
- **[aslp][]**: the ASLp partial evaluator with ARM's MRA,
- **[bap-aslp][]**: a version of official BAP with a bundled ASLp plugin, 
- **[bap-uq-pac][]**: PAC's fork of BAP with the [Primus Lisp PR][] but without ASLp, and
- **[basil][]**: the Basil tool for analysis and transpilation to Boogie code.

[aslp]: https://github.com/UQ-PAC/aslp
[bap-aslp]: https://github.com/UQ-PAC/bap-asli-plugin
[bap-uq-pac]: https://github.com/UQ-PAC/bap/tree/aarch64-pull-request-2
[Primus Lisp PR]: https://github.com/BinaryAnalysisPlatform/bap/pull/1546
[basil]: https://github.com/UQ-PAC/bil-to-boogie-translator

These are each defined in a .nix file of the same name,
then instantiated within overlay.nix and
built into a package set in pkgs.nix.

## usage

To use these, you will need the Nix package manager
from [nixos.org][] (if able, a multi-user install is preferred).
This should extend your PATH with ~/.nix-profile/bin which is where
installed binaries will go.

[nixos.org]: https://nixos.org/download

First, add this repository as a Nix channel called "pac" and update its contents.
As your usual user, run:
```bash
nix-channel --add https://github.com/katrinafyi/pac-nix/archive/refs/heads/main.tar.gz pac
nix-channel --update
```

Installing a package is straightforward.
```bash
nix-env -iA pac.aslp  # or pac.bap-aslp or pac.basil
```
This will build and make available an executable in ~/.nix-profile/bin.

Note that this will install the package at a particular commit hash from the upstream repository.
The next sections will discuss building a package
from local sources and setting up development environments.

To list installed package:
```bash
nix-env -q
```

To uninstall, use the name from `-q` with `--uninstall`.
```bash
nix-env --uninstall aslp-unstable-2023-09-18
```

To re-install or rebuild a changed package,
you can re-run the install command.

Nix is powerful but the documentation is of mixed quality.
[nix-tutorial](https://nix-tutorial.gitlabpages.inria.fr/nix-tutorial/getting-started.html)
introduces some other commands.
Otherwise, it will be useful to search as far as you can.

### bonus: binary cache

The GitHub Actions workflow maintains a custom binary cache for this repository.
Using this cache, you can install these Nix packages while avoiding the need to run any compilations yourself.
This can save a fair bit of bandwidth and time.

The cache is served at [pac-nix.cachix.org](https://pac-nix.cachix.org/) and can be used like so:
```bash
# install the cachix tool
nix-env -iA cachix -f https://cachix.org/api/v1/install
# configure nix to use cache. you may need to trust your username
cachix use pac-nix
```
Then, `nix-env` should draw from this cache in addition to the usual Nixpkgs cache. This will be visible in its output:
```
copying path '/nix/store/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa-ocaml4.14.1-bap-2.5.0' from 'https://cache.nixos.org'...
copying path '/nix/store/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa-bap-aslp-2.5.0' from 'https://pac-nix.cachix.org'...
```

## local sources / customisation

It is often useful to build a package from
a clone of the repository on your local computer
(e.g. to test your un-committed changes).

To do this, we will override the _src_ attribute of
the corresponding build package.
In overlay.nix, some packages have commented overrideAttrs lines.
These are the build packages which are wrapped into the user-facing tools.

To use local sources, simply uncomment the line and change the path
to be your local path.
(It is important the path is not quoted so Nix handles it correctly.)

Further customisation can also be done here.
The JRE and JDK are currently fixed to Java 17,
and you may also add more Nix files or override other attributes.

## development environments

With each package, Nix also downloads and stores its dependencies.
As such, you may want to re-use these when developing instead of
duplicating them into your local system.
This may also speed up the getting-started process and make it more reliable. 

This is done with the `nix-shell` which
starts a subshell within a particular Nix environment.

The most basic usage is something like
```
nix-shell -p hello
```
which spawns a shell with the `hello` binary.

Unfortunately, this doesn't work for us since
our packages aren't in \<nixpkgs\>.

We use a \*-shell.nix file to define a development shell.
One example is in asli-shell.nix which can be used to develop ASLi.

You can copy this format to make other shells.
The first line should maintain the `import ./pkgs.nix`
to load our local package set.
_inputsFrom_ defines the package(s) whose dependencies we will load
(i.e. what we want to build),
and _packages_ are packages to make available
(i.e. compile-time or dev dependencies).

To use a shell file, run:
```bash
nix-shell ./asli-shell.nix
```
From within the shell, you can start IDEs and
tools to inherit the environment.

See also: [nix-shell manual page](https://nixos.org/manual/nix/stable/command-ref/nix-shell).

## updating packages

Periodically, these Nix files will need to be updated with new changes from upstream.
A daily GitHub action will attempt to update all packages.
Its most recent status is shown at the top of this README.

The update process is automated by a script:
```bash
./update.py do-upgrade  # or `./update.py check` to check only
```
This will update the hash in each Nix file with the latest then attempt to build the new packages.
If successful, this will commit the changes.

The basil derivation is most fragile since it relies on SBT to fetch its dependencies.
The depsSha256 will need to be changed manually if the script fails at that point.

## miscellany

[search.nixos.org](https://search.nixos.org/)
is very useful for searching package names.

[Nix pills](https://nixos.org/guides/nix-pills/) are a good resource 
if you wish to write your own packages.
It is also a good idea to browse the [nixpkgs](https://github.com/NixOS/nixpkgs/) monorepo for similar derivations.

Nix can also bundle a package into a standalone executable or AppImage
with [nix-bundle](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-bundle).

