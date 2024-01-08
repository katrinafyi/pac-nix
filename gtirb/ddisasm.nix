{ lib
, stdenv
, fetchFromGitHub
, cmake
, boost
, lief
, libehp
, gtirb
, gtirb-pprinter
, capstone-grammatech
, souffle
}:

stdenv.mkDerivation {
  pname = "ddisasm";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "GrammaTech";
    repo = "ddisasm";
    rev = "v1.8.0";
    hash = "sha256-jCJLqy1BARO9SjV6hzSaow/KdMLlIc+wNXC16LSLlVE=";
  };

  buildInputs = [ cmake boost lief gtirb gtirb-pprinter libehp ];
  nativeBuildInputs = [ capstone-grammatech souffle ];

  cmakeFlags = [ "-DDDISASM_ENABLE_TESTS=OFF" "-DDDISASM_GENERATE_MANY=ON" ];
  # enableParallelBuilding = false;

  preConfigure = ''
    export CXXFLAGS='-includeset' 
  '';

  meta = {
    homepage = "https://github.com/grammatech/ddisasm";
    description = "A fast and accurate disassembler.";
    maintainers = [ "Kait Lam <k@rina.fyi>" ];
  };
}

