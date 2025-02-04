{ stdenv
, fetchFromGitHub
, clang17Stdenv
, cmake
}:

let
  stdenv' = if stdenv.isDarwin then clang17Stdenv else stdenv;
in stdenv'.mkDerivation {
  pname = "aslp-cpp";
  version = "0.0.1-unstable-2025-02-03";

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp-rpc";
    rev = "cb0a294275c945f5be2a82b689bbc42a54af28f2";
    hash = "sha256-t8D17pykyDcJBCj/WUMEZpA2t8m8EqnlD6FhHx+4D8k=";
  };

  prePatch = ''
    cd aslp-client-http-cpp
  '';

  patches = [ ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [ ];

  cmakeFlags = [ ];
}
