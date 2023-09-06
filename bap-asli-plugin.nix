{ stdenv,
  lib,
  asli,
  ocamlPackages, 
  fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "bap-asli-plugin";
  version = src.rev;

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "bap-asli-plugin";
    rev = "6802ea4a2a39b8655dcc1833651011ee01018308";
    sha256 = "sha256-INlPlm33Z+Fv04I+b5nROLRsCuthOzvf094WQC7nqrg=";
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
