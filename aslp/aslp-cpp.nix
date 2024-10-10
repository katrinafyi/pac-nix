{ stdenv
, cmake
, asli
, overrideCC
, llvmPackages_17
}:

let buildStdenv = if stdenv.isDarwin then overrideCC stdenv llvmPackages_17.clang else stdenv; in

buildStdenv.mkDerivation {
  pname = "aslp-cpp";
  version = asli.version;

  src = "${asli.src}/aslp-cpp";

  patches = [ ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [ ];

  cmakeFlags = [ ];
}
