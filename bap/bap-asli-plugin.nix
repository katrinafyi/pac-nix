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
  version = "0-unstable-2024-12-04";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "bap-asli-plugin";
    rev = "ad9c51b12f721317568f94181197d8ff4a01b1d3";
    sha256 = "sha256-gVWqOoHhHpNxubM5UZyFyvZnauWdwSTE882OYLd13HA=";
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
