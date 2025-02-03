{ stdenv
, fetchFromGitHub
, clang17Stdenv
, cmake
}:

let
  stdenv' = if stdenv.isDarwin then clang17Stdenv else stdenv;
in stdenv'.mkDerivation {
  pname = "aslp-cpp";
  version = "0-unstable-2025-02-03";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp-rpc";
    rev = "12a5dfbda19429cc0c52f941ef67d184b227e3a4";
    hash = "sha256-zsqdxE6HqqSZ86rMF32yTzUEz97mywSKrn3qndmxrDI=";
  };

  prePatch = ''
    cd aslp-client-http-cpp
  '';

  patches = [ ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [ ];

  cmakeFlags = [ ];
}
