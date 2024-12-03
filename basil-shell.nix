{ mkShell
, gcc-aarch64
, clang-aarch64
, asli
, ddisasm
, bap-aslp
, coreutils
, gtirb-pprinter
, gtirb-semantics
, pkgsCross
}:
let
  packages = [
    pkgsCross.aarch64-multiplatform.pkgsBuildHost.gcc

    pkgsCross.aarch64-multiplatform-musl.pkgsBuildHost.gcc

    bap-aslp
    asli
    ddisasm
    gtirb-pprinter
    gtirb-semantics
  ];
in mkShell {
  inherit packages;
  inputsFrom = [ ];
  shellHook = ''
    echo
    echo == pac-nix/BASIL tool shell ==
    echo
    echo 'with packages installed:'
    printf ' - %s\n' ${toString (map (x: x.name) packages)}
    echo
  '';
  meta = {
    description = "shell containing tools used in the BASIL pipeline"; 
  };
}
