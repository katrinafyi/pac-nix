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
    rev = "4deea4f561853388dd54fcb2ccae14bd9bbe22e1";
    hash = "sha256-PbZNrFFXNVvnuwTeiDtil6jMKHqPddvTGYpQnnbhJ5Q=";
  };

  prePatch = ''
    cd aslp-client-http-cpp
  '';

  patches = [ ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [ ];

  cmakeFlags = [ ];
}
