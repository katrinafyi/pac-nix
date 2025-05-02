{ mkShell
, gcc-aarch64
, clang-aarch64
, asli
, ddisasm
, bap-aslp
, bap-asli-plugin
, gtirb-pprinter
, gtirb-semantics
, pkgsCross
, extraPackages ? []
}:
let
  packages = [
    pkgsCross.aarch64-multiplatform.pkgsBuildHost.gcc
    pkgsCross.aarch64-multiplatform.pkgsBuildHost.clang

    pkgsCross.aarch64-multiplatform-musl.pkgsBuildHost.gcc
    pkgsCross.aarch64-multiplatform-musl.pkgsBuildHost.clang

    asli

    # bap-aslp
    # bap-asli-plugin

    ddisasm
    gtirb-pprinter
    gtirb-semantics
  ] ++ extraPackages;
in mkShell {
  inherit packages;
  inputsFrom = [ ];
  shellHook = ''
    echo
    echo == pac-nix/BASIL tool shell ==
    echo
    echo 'with packages installed:'
    printf ' - %s\n' ''$PACKAGES
    echo
  '';

  PACKAGES = toString (map (x: x.name) packages);

  meta = {
    description = "shell containing tools used in the BASIL pipeline";
  };

  hardeningDisable = [ "all" ];
}
