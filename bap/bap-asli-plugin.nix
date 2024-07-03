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
  version = "unstable-2023-09-11";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "bap-asli-plugin";
    rev = "cfe67145faaf43b29e9e12d533cce34b95c28ed1";
    sha256 = "sha256-CsdUjXHHVisfiTP2XGOHfm+Aa23KZep4IdgoYHQsnXg=";
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
