{ lib
, stdenv
, fetchFromGitHub
# ocamlPackages
, ocaml
, findlib
, asli
, bap-build
, bap
}:

stdenv.mkDerivation rec {
  pname = "bap-asli-plugin";
  version = "0-unstable-2025-04-16";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "bap-asli-plugin";
    rev = "0b86c3a6437c32d5b4dc6d7121f8ec4497bc4185";
    sha256 = "sha256-NvmIuftrsoASH82fCf14PQ7Q4DwreRuMOI8XyrV6vFg=";
  };

  buildInputs = [ asli bap findlib ];
  nativeBuildInputs = [ ocaml ];
  dontDetectOcamlConflicts = true;

  patches = [ ./0001-asli_lifter.ml-use-FileSource-type.patch ];

  buildPhase = ''
    runHook preBuild

    OCAMLRUNPARAM=b ${bap-build}/bin/bapbuild -package asli.libASL asli.plugin -dont-catch-errors
    mkdir -p $out/lib/bap

    # needed to maintain runtime dependencies.
    # asli.plugin loses these because it is a compressed file.
    mkdir $out/lib/bap/asli.plugin-deps/
    cp -rv _build/*.cmxs $out/lib/bap/asli.plugin-deps/

    cp -v asli.plugin $out/lib/bap

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    runHook postInstall
  '';
}
