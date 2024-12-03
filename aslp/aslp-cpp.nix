{ stdenv
, clang17Stdenv
, cmake
, asli
}:

let stdenv' = if stdenv.isDarwin then clang17Stdenv else stdenv;

in stdenv'.mkDerivation {
  pname = "aslp-cpp";
  version = asli.version;

  src = "${asli.src}/aslp-cpp";

  patches = [ ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [ ];

  cmakeFlags = [ ];
}
