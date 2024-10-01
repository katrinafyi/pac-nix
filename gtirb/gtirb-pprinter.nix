{ lib
, stdenv
, fetchFromGitHub
, cmake
, python3
, boost
, abseil-cpp
, doxygen
, gtirb
, capstone-grammatech
, gtest
}:

stdenv.mkDerivation {
  pname = "gtirb-pprinter";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "GrammaTech";
    repo = "gtirb-pprinter";
    rev = "v2.1.0";
    hash = "sha256-zgYq6FKxaJ6vLzvOTCfOU4ZUyXvMuFc3abNrqg8NADc=";
  };
  patches = [ ./0001-gtirb_pprinter-include-map.patch ];

  buildInputs = [ cmake python3 gtirb boost abseil-cpp gtest ];
  nativeBuildInputs = [ capstone-grammatech ];

  cmakeFlags = [ "-DGTIRB_PPRINTER_ENABLE_TESTS=OFF" ];

  preConfigure = ''
    export CXXFLAGS='-includecstdint -includeset -Wno-error=unused-result -Wno-error=deprecated-declarations -Wno-error=array-bounds'
  '';

  meta = {
    homepage = "https://github.com/grammatech/gtirb-pprinter";
    description = "Pretty printer from GTIRB to assembly code.";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}

