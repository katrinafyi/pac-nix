{ stdenv
, fetchFromGitHub
, clang17Stdenv
, cmake
}:

let
  stdenv' = if stdenv.isDarwin then clang17Stdenv else stdenv;
  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "aslp-rpc";
    rev = "1a31d940e47246e24fb45cbc5614f24e425566ca";
    hash = "sha256-o5+vNRIM0NslWc2NpgPuzdkVFlWmb6lMUGgNQvuNC60=";
  };
in stdenv'.mkDerivation {
  pname = "aslp-cpp";
  version = "0.1";

  src = "${src}/aslp-client-http-cpp";

  patches = [ ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [ ];

  cmakeFlags = [ ];
}
