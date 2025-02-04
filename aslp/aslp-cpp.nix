{ stdenv
, fetchFromGitHub
, clang17Stdenv
, cmake
}:

let
  stdenv' = if stdenv.isDarwin then clang17Stdenv else stdenv;
in stdenv'.mkDerivation {
  pname = "aslp-cpp";
  version = "0.1.1-unstable-2025-02-04";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp-rpc";
    rev = "9ae165336d70e8f0c8aaf075fdfb02d86de11097";
    hash = "sha256-3p8WNnbwA//y3Vf5VbibGcZUfU0IBtCRzXCLM1RZeps=";
  };

  prePatch = ''
    cd aslp-client-http-cpp
  '';

  patches = [ ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [ ];

  cmakeFlags = [ ];
}
