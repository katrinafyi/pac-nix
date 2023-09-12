{ stdenv,
  lib,
  asli,
  ocamlPackages, 
  fetchFromGitHub
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

  buildInputs = [ asli ocamlPackages.bap ocamlPackages.findlib ];

  buildPhase = ''
    runHook preBuild

    bapbuild -package asli.libASL asli.plugin
    mkdir -p $out
    cp asli.plugin $out/asli.plugin

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    runHook postInstall
  '';
}
