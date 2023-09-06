# pac-nix

An experiment to package [PAC](https://github.com/UQ-PAC)'s
tools with the Nix package manager.

This repository contains fixed-output derivations which fetch
and build a fixed version of each tool and its dependencies.
Nix's declarative nature makes this fast and reliable, 
independent of particular distributions or their package repository quirks.
Further, since each dependency is itself a static derivation, these can be cached.
z3 and BAP, which previously took dozens of minutes each,
are fetched in seconds.

Overall, Nix is an effective and well-suited to this task
of a consistent meta-build and dependency manager system.

## structure

The **pkgs.nix** file defines the package set as 
the usual \<nixpkgs\> extended with those from this repo.

For users of tools, the main packages are:
- **aslp**: the ASLp partial evaluator with ARM's MRA,
- **bap-aslp**: a version of BAP with an integrated ASLp plugin, and
- **basil**: the Basil tool for analysis and transpilation to Boogie code.

These are each defined in a .nix file of the same name,
then instantiated within overlay.nix and
built into a package set in pkgs.nix.

## usage

To use these, you will need the Nix package manager
from https://nixos.org/download (if able, a multi-user install is preferred).
This should extend your PATH with ~/.nix-profile/bin which is where
installed binaries will go.

Installing a package is straightforward.
From this directory, run this as your normal user:
```bash
nix-env -f ./pkgs.nix -iA aslp  # or bap-aslp or basil
```
For the tools listed above, this should build
and make available an executable ~/.nix-profile/bin.

Note that these will fetch each tool's repository
at a particular hash and build from that revision.
The next sections will discuss building a package
from local sources and setting up development environments.

To uninstall, use:
```bash
nix-env --uninstall aslp
```

To re-install or rebuild a changed package,
you can re-run the install command.

Nix is powerful but the documentation is of mixed quality.
[nix-tutorial](https://nix-tutorial.gitlabpages.inria.fr/nix-tutorial/getting-started.html)
introduces some other commands.
Otherwise, it will be useful to search as far as you can.

## local sources / customisation

It is often useful to build a package from
a copy of the repository on your local computer
(e.g. to test your un-committed changes).

To do this, we will need to override the _src_ attribute of
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

## miscellany

[Nix pills](https://nixos.org/guides/nix-pills/) are useful 
if you wish to write your own packages.
It is also a good idea to browse the [nixpkgs](https://github.com/NixOS/nixpkgs/) monorepo for similar derivations.

Nix can also bundle a package into a standalone executable or AppImage
with [nix-bundle](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-bundle).

