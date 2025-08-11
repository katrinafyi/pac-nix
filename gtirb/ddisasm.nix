{ lib
, stdenv
, fetchurl
, fetchFromGitHub
, fetchzip
, cmake
, boost
, lief
, libehp
, gtirb
, gtirb-pprinter
, capstone-grammatech
, souffle
, ddisasm
, runCommand
, testers
, jq
}:

let
  elf-test-files = fetchzip {
    url = "https://gist.github.com/katrinafyi/8bcc7a6756b6f467a658e292181cdf8b/archive/453c9b2c5ebdca4d30816e26805b121a919dd150.tar.gz";
    hash = "sha256-xewqpzAR+rfAMM9Hn97gwzTrhpHONjltbIjhd15PaPw=";
  };
in stdenv.mkDerivation {
  pname = "ddisasm";
  version = "1.8.0-unstable-2025-07-14";

  src = fetchFromGitHub {
    owner = "GrammaTech";
    repo = "ddisasm";
    rev = "5a8779f427ddfecd085f5bfd86c3a2006251ef8d";
    hash = "sha256-ZSmm+uwfXvTRRiLFLZVy2XOSI/rFd5piJ+8J+s2lJG8=";
  };

  patches = [
    (fetchurl {
      url = "https://github.com/rina-forks/ddisasm/compare/main..determinism.patch";
      hash = "sha256-xISyR7ptR2LfHZJAGUyXqANLIab9yZrQFh8wLbJLsx8=";
    })
  ] ++ lib.optional stdenv.isDarwin ./0001-ddisasm-disable-concurrent-souffle.patch;

  buildInputs = [ cmake boost lief gtirb gtirb-pprinter libehp ];
  nativeBuildInputs = [ capstone-grammatech souffle ];

  cmakeFlags = [ "-DDDISASM_ENABLE_TESTS=OFF" "-DDDISASM_GENERATE_MANY=ON" ];

  postPatch = ''
    (
    shopt -s globstar
    substituteInPlace **/*.cpp **/*.h --replace-warn unordered_map map --replace-warn unordered_set set
    substituteInPlace src/passes/Disassembler.cpp \
      --replace-fail \
      'gtirb::UUID Uuid;' \
      'gtirb::UUID Uuid{gtirb::Node::UUIDGenerator()};'
    )
  '';

  passthru.deterministic = ddisasm;

  passthru.tests.ddisasm = testers.testVersion {
    package = ddisasm;
    command = "ddisasm --help || true";
    version = "Disassemble";
  };

  passthru.tests.ddisasm-deterministic = runCommand
    "ddisasm-deterministic-test"
    { nativeBuildInputs = [ ddisasm.deterministic jq ]; }
    ''
      mkdir -p $out && cd $out
      cp -v ${elf-test-files}/a.out .
      ddisasm a.out --json | jq -S > a1
      ddisasm a.out --json | jq -S > a2
      diff -u a1 a2
    '';

  meta = {
    mainProgram = "ddisasm";
    homepage = "https://github.com/grammatech/ddisasm";
    description = "A fast and accurate disassembler.";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}

