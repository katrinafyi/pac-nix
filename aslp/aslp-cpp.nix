{ stdenv
, lib
, cmake
, asli
}:

stdenv.mkDerivation {
  pname = "aslp-cpp";
  version = asli.version;

  src = asli.src;
  unpackPhase = "cp -r --no-preserve=mode $src source";
  sourceRoot = "source/aslp-cpp";

  patches = [ ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [ ];

  cmakeFlags = [ ];
}
