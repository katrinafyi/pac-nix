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

# store@@future:
"pkgs@future" = {
  gcc = "gcc-8";
  ocaml = "ocaml-5.7 using gcc-8";
  ocamlformat =
    "ocamlformat-1.1 using ocaml-6.0 using gcc-8";
}
