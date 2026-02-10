{ stdenv
, fetchFromGitHub
, clang17Stdenv
, cmake
}:

stdenv.mkDerivation {
  pname = "aslp-cpp";
  version = "0.1.4-unstable-2026-02-09";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp-rpc";
    rev = "001b2f954412466fce56c312a9258c3c4698ea6a";
    hash = "sha256-AIAfLaTlXOU7QW2/Pk98pA6FoE0SJtzvXFsfmFCy6Ao=";
  };

  prePatch = ''
    cd aslp-client-http-cpp
  '';

  patches = [ ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [ ];

  cmakeFlags = [ ];
}
