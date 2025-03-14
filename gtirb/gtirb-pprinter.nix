{ lib
, stdenv
, fetchFromGitHub
, cmake
, python3
, boost183
, abseil-cpp
, doxygen
, gtirb
, capstone-grammatech
, gtest
}:

stdenv.mkDerivation {
  pname = "gtirb-pprinter";
  version = "2.2.0-unstable-2024-10-09";

  src = fetchFromGitHub {
    owner = "GrammaTech";
    repo = "gtirb-pprinter";
    rev = "762a287f3d12c6aac3d3d000cdc8bf20f5ee34f2";
    hash = "sha256-9CZ+ndHX5f4rKbGXvCrqEg55Ep9JEkS/u//grdqTpTc=";
  };

  patches = [ ./0001-gtirb_pprinter-include-map.patch ];

  postPatch = ''
    (
    shopt -s globstar
    substituteInPlace **/*.cpp **/*.hpp --replace-warn unordered_map map --replace-warn unordered_set set
    )
  '';

  buildInputs = [ cmake python3 gtirb boost183 abseil-cpp gtest ];
  nativeBuildInputs = [ capstone-grammatech ];

  cmakeFlags = [ "-DGTIRB_PPRINTER_ENABLE_TESTS=OFF" ];
  CXXFLAGS= [
    "-includecstdint"
    "-includeset"
    "-Wno-error=unused-result"
    "-Wno-error=deprecated-declarations"
    "-Wno-error=array-bounds"
  ];

  meta = {
    homepage = "https://github.com/grammatech/gtirb-pprinter";
    description = "Pretty printer from GTIRB to assembly code.";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}

