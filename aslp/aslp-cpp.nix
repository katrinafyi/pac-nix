{ stdenv
, cmake
, asli
}:

stdenv.mkDerivation {
  pname = "aslp-cpp";
  version = asli.version;

  src = "${asli.src}/aslp-cpp";

  patches = [ ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [ ];

  cmakeFlags = [ ];
}
