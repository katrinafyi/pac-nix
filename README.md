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
- **[aslp][]**: the ASLp partial evaluator with ARM's MRA (provides `aslp`),
- **[bap-aslp][]**[^1]: a version of official BAP with a bundled ASLp plugin (this is the preferred BAP and provides the `bap` executable), 
- **[basil][]**: the Basil tool for analysis and transpilation to Boogie code (provides `basil`),
- **[ddisasm][]**: GrammaTech's datalog disassembler (provides `ddisasm`), and
- **[gtirb-semantics][]**: inserts instruction semantics from ASLp into the GTIRB from ddisasm (provides `gtirb-semantics`).


[aslp]: https://github.com/UQ-PAC/aslp
[bap-aslp]: https://github.com/UQ-PAC/bap-asli-plugin
[bap-primus]: https://github.com/UQ-PAC/bap/tree/aarch64-pull-request-2
[Primus Lisp PR]: https://github.com/BinaryAnalysisPlatform/bap/pull/1546
[basil]: https://github.com/UQ-PAC/bil-to-boogie-translator
[ddisasm]: https://github.com/GrammaTech/ddisasm
[godbolt]: https://github.com/ailrst/compiler-explorer
[gtirb-semantics]: https://github.com/UQ-PAC/gtirb-semantics

The packages are each defined in a .nix file of the same name,
then instantiated within overlay.nix and
built into a package set in pkgs.nix.

<details>
<summary>Other packages</summary>
These are less frequently used and might be untested.
  
- **[bap-primus][]**: PAC's fork of BAP with the [Primus Lisp PR][] but without ASLp (provides `bap-primus`)
- **[godbolt][]**: the Godbolt compiler explorer with the Basil toolchain for interactive use (provides `godbolt`)

Other Nix files also define dependencies needed by the end-user tools.
</details>

[^1]: Due to the plugin loading method, `bap-mc -- [bytecode]` will not work to disassemble one opcode. Instead, you should omit the `--` or pipe the bytes via stdin `echo [bytecode] | bap-mc`.

## usage

### first time
To use these, you will need the Nix package manager
from [nixos.org][] (if able, a multi-user install is preferred).
This should extend your PATH with ~/.nix-profile/bin which is where
installed binaries will go.

[nixos.org]: https://nixos.org/download

First, set up your user with Nix:
```bash
cat <<EOF | sudo tee -a /etc/nix/nix.conf
extra-experimental-features = nix-command flakes
extra-trusted-users = $USER
EOF
```
<!--
As your usual user, run:
```bash
nix-channel --add https://github.com/katrinafyi/pac-nix/archive/refs/heads/main.tar.gz pac
nix-channel --update
```

<blockquote>
<details>
  <summary>
    <b>note</b>: if you see &ldquo;error: file 'nixpkgs' was not found in the Nix search path&rdquo;
  </summary>

  Use these commands to add the \<nixpkgs\> repository.
  ```bash
  nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
  nix-channel --update
  ```
  If these commands raise "permission denied", you can also try them with `sudo`.
  Be aware that using sudo here might require sudo in later commands as well.
</details>
</blockquote>
-->

### installing packages

Installing a package is straightforward.
```bash
nix profile install github:katrinafyi/pac-nix#aslp  # add -Lv for more progress output
# say 'y' to config settings
```
For other packages, change the term after `#` to bap-aslp, basil, etc. 
This will build and make available an executable on your PATH (stored in ~/.nix-profile/bin).

Note that this will install the package at a particular commit hash from the upstream repository.
The next sections will discuss building a package
from local sources and setting up development environments.

To list available packages:
```bash
nix flake show github:katrinafyi/pac-nix
```

To list installed packages:
```bash
nix profile list
```

To uninstall, use the *index* from `nix profile list` in this command:
```bash
nix profile remove 1234
```

To re-install or rebuild a changed package,
you can re-run the install command.

Nix is powerful but the documentation is of mixed quality.
[nix-tutorial](https://nix-tutorial.gitlabpages.inria.fr/nix-tutorial/getting-started.html)
introduces some other commands.
Otherwise, it will be useful to search as far as you can.

#### garbage collection

The /nix/store folder can get quite large.
You can use these commands to clean it up.

```bash
nix-collect-garbage --delete-older-than 1d  # or --delete-old
nix-store --gc
```

nix-env creates a snapshot of your packages (a generation) after each package operation.
This keeps those old packages inside your Nix store.
These commands will delete stale generations then delete their packages from the store. 

### bonus: binary cache

The GitHub Actions workflow maintains a custom binary cache for this repository.
Using this cache, you can install these Nix packages while avoiding the need to run any compilations yourself.
This can save a fair bit of bandwidth and time.

The cache is served at [pac-nix.cachix.org](https://pac-nix.cachix.org/) and should be used automatically
by the instructions above. This will be visible in its output:
<!--can be used like so:
```bash
# install the cachix tool
nix-env -iA cachix -f https://cachix.org/api/v1/install
# configure nix to use cache. you may need to trust your username
cachix use pac-nix
```
-->

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

