let mkdrv = x: x; in

# nixpkgs@main:
rec {
  gcc = mkDrv "gcc-7";
  ocaml = mkDrv "ocaml-5.5 using ${gcc}";
  ocamlformat =
    mkDrv "ocamlformat-1.0 using ${ocaml}";
  ghc = mkDrv "ghc-9.11 using ${gcc}";
}

# store@main:
{
  gcc = "gcc-7";
  ocaml = "ocaml-5.5 using gcc-7";
  ocamlformat =
    "ocamlformat-1.0 using ocaml-5.5 using gcc-7";
  ghc = "ghc-10 using gcc-7";
}

# nixpkgs@future:
{
  gcc = mkDrv "gcc-8";
  ocaml = mkDrv "ocaml-5.7 using ${gcc}";
  ocamlformat = mkDrv "ocamlformat-1.1 using ${ocaml}";
}
let x = 2; in (let y = x + 1; in x + y)

# store@@future:
"pkgs@future" = {
  gcc = "gcc-8";
  ocaml = "ocaml-5.7 using gcc-8";
  ocamlformat =
    "ocamlformat-1.1 using ocaml-6.0 using gcc-8";
}

# functions are applied with space!
fetchpatch { url = "http://"; hash = "hash"; }
# => «derivation /nix/store/fz96k34rsjwwllk7c2f4zncprd5vxgbb-unknown.drv»

# let's put it into a list...
patches = [
  fetchpatch { url = "http://"; hash = "hash"; }
]

let x = 2 in x + 1

# spaces separate list items ;-;
nix-repl> [ 1 2 ]
[
  1
  2
]


nix-repl> [ fetchpatch { url = "http://"; hash = "hash"; } ]
[
  {
    __functionArgs = {
      decode = true;
      excludes = true;
      extraPrefix = true;
      includes = true;
      postFetch = true;
      relative = true;
      revert = true;
      stripLen = true;
    };
    __functor = «lambda __functor @ /nix/store/23j07cz2f9rrdjmbfkwp68x5gk8czrh0-nixpkgs/nixpkgs/lib/trivial.nix:440:19»;
    override = {
      __functionArgs = {
        fetchurl = false;
        lib = false;
        patchutils = false;
      };
      __functor = «lambda __functor @ /nix/store/23j07cz2f9rrdjmbfkwp68x5gk8czrh0-nixpkgs/nixpkgs/lib/trivial.nix:440:19»;
    };
    tests = {
      decode = «derivation /nix/store/zdgblm25yydmrgm4h5f0kjmg90y97wkc-gcc.patch-salted-lx38nn13pwa8.drv»;
      full = «derivation /nix/store/zlck97p62hzr452x0rrzkffjrkzm7x5y-source-salted-x490i8ylw74x.drv»;
      override = {
        __functionArgs = { };
        __functor = «lambda __functor @ /nix/store/23j07cz2f9rrdjmbfkwp68x5gk8czrh0-nixpkgs/nixpkgs/lib/trivial.nix:440:19»;
      };
      overrideDerivation = «lambda overrideDerivation @ /nix/store/23j07cz2f9rrdjmbfkwp68x5gk8czrh0-nixpkgs/nixpkgs/lib/customisation.nix:111:32»;
      relative = «derivation /nix/store/j63si6ppl372rnzxnbsnnh8q4sd80b9f-source-salted-7m6g3xrd318k.drv»;
      simple = «derivation /nix/store/78ca9l1hbm68bvwzgwwms8l3p39z30a3-source-salted-q72wrc33kp1l.drv»;
    };
    version = 1;
  }
  {
    hash = "hash";
    url = "http://";
  }
]

# => [ «derivation /nix/store/fz96k34rsjwwllk7c2f4zncprd5vxgbb-unknown.drv» ]



nix-repl> let x = 2 in x + 1

error: syntax error, expecting ';' to end binding
       at «string»:1:11:
            1| let x = 2 in x + 1
             |           ^


# ok fine...
nix-repl> let x = 2; in x + 1
3

# i wonder if we can reference earlier names...
nix-repl> let x = 2; y = x + 1; in x + y
5

let x = 2; in let y = x + 1; in x + y

# ... can we reference later names?
nix-repl> let y = x + 1; x = 2; in x + y

nix-repl> let in 5
5

nix-repl> rec { x = y + 3; y = 2; }
{
  x = 5;
  y = 2;
}

nix-repl> { a.b.c = 3; a.b.d = 4; }
{
  a = {
    b = {
      c = 3;
      d = 4;
    };
  };
}


nix-repl> 4.0e1 / 2                        
20

nix-repl> 4.0e1/ 2
20

nix-repl> 4.0e1 /2
error: attempt to call something which is not a function but a float: 40
       at «string»:1:1:
            1| 4.0e1 /2
             | ^

nix-repl> /2
/2

nix-repl> 4.0e1/2  
/home/rina/progs/pac-nix/4.0e1/2

