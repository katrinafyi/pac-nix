{ stdenv
, fetchFromGitHub
, clang17Stdenv
, cmake
}:

let
  stdenv' = if stdenv.isDarwin then clang17Stdenv else stdenv;
in stdenv'.mkDerivation {
  pname = "aslp-cpp";
  version = "0.1.5-unstable-2026-05-29";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp-rpc";
    rev = "b3cd2aaf73771a3e43a4ee113c174f7fef238cb5";
    hash = "sha256-3K/DiuYjj7B71GvzzJN/0e4wiCh15l8rbeVpDuk1ypk=";
  };

  prePatch = ''
    cd aslp-client-http-cpp
  '';

  patches = [ ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [ ];

  cmakeFlags = [ ];
}
