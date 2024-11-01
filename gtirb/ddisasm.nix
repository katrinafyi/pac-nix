{ lib
, stdenv
, fetchurl
, fetchFromGitHub
, cmake
, boost
, lief
, libehp
, gtirb
, gtirb-pprinter
, capstone-grammatech
, souffle
, ddisasm
, runCommandCC
, testers
, jq
}:

stdenv.mkDerivation {
  pname = "ddisasm";
  version = "0-unstable-2024-10-31";

  src = fetchFromGitHub {
    owner = "GrammaTech";
    repo = "ddisasm";
    rev = "17396b59537aaff73e2c7657ccd3b3eb2c3b6a04";
    hash = "sha256-yFZ0QR1upmTzEyATsTM5bGPr0EPWxkyXKbGa5nYSEIE=";
  };

  patches = [
    (fetchurl {
      url = "https://github.com/rina-forks/ddisasm/compare/main..determinism.patch";
      hash = "sha256-xISyR7ptR2LfHZJAGUyXqANLIab9yZrQFh8wLbJLsx8=";
    })
  ];

  buildInputs = [ cmake boost lief gtirb gtirb-pprinter libehp ];
  nativeBuildInputs = [ capstone-grammatech souffle ];

  cmakeFlags = [ "-DDDISASM_ENABLE_TESTS=OFF" "-DDDISASM_GENERATE_MANY=ON" ];

  CXXFLAGS = [ "-includeset" ];

  passthru.deterministic = ddisasm;

  passthru.tests.ddisasm = testers.testVersion {
    package = ddisasm;
    command = "ddisasm --help || true";
    version = "Disassemble";
  };

  passthru.tests.ddisasm-deterministic = runCommandCC
    "ddisasm-deterministic-test"
    { nativeBuildInputs = [ ddisasm.deterministic jq ]; }
    ''
      mkdir -p $out && cd $out
      echo 'int main(void) { return 0; }' > a.c
      $CC a.c
      ddisasm a.out --json | jq -S > a1
      ddisasm a.out --json | jq -S > a2
      diff -q a1 a2
    '';

  meta = {
    mainProgram = "ddisasm";
    homepage = "https://github.com/grammatech/ddisasm";
    description = "A fast and accurate disassembler.";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}

