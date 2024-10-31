{ lib
, stdenv
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
, makeWrapper
, runCommand
, clang-aarch64
, unrandom
, testers
, jq
}:

stdenv.mkDerivation {
  pname = "ddisasm";
  version = "unstable-2024-03-08";

  src = fetchFromGitHub {
    owner = "GrammaTech";
    repo = "ddisasm";
    rev = "9edfe9fe86910ef946de1db7a7ac41ce86bc31d0";
    hash = "sha256-xFW6J3jCCMtUqT25/zVfjjy5o3MoX1HXxIlRhjM6s8A=";
  };
  patches = if stdenv.isDarwin then [ ./0001-ddisasm-disable-concurrent-souffle.patch ] else null;

  buildInputs = [ cmake boost lief gtirb gtirb-pprinter libehp ];
  nativeBuildInputs = [ capstone-grammatech souffle ];

  cmakeFlags = [ "-DDDISASM_ENABLE_TESTS=OFF" "-DDDISASM_GENERATE_MANY=ON" ];

  CXXFLAGS = "-includeset";

  passthru.deterministic =
    runCommand
      (ddisasm.name + "-deterministic")
      { nativeBuildInputs = [ makeWrapper ]; }
      ''
        makeWrapper ${lib.getExe ddisasm} $out/bin/ddisasm-deterministic \
          --inherit-argv0 \
          --suffix LD_PRELOAD : ${lib.getLib unrandom}/lib/*.so
      '';

  passthru.tests.ddisasm = testers.testVersion {
    package = ddisasm;
    command = "ddisasm --help || true";
    version = "Disassemble";
  };

  # Deterministic fix does not work on Darwin, just test to see if ddisasm even runs
  passthru.tests.ddisasm-deterministic =
    let
      test-files = fetchzip {
        url = "https://gist.github.com/katrinafyi/8bcc7a6756b6f467a658e292181cdf8b/archive/453c9b2c5ebdca4d30816e26805b121a919dd150.tar.gz";
        hash = "sha256-xewqpzAR+rfAMM9Hn97gwzTrhpHONjltbIjhd15PaPw=";
      };
    in runCommand
      "ddisasm-deterministic-test"
      { nativeBuildInputs = [ ddisasm.deterministic jq ]; }
      (
      ''
        cp -v ${test-files}/a.out .
        ddisasm-deterministic a.out --json | jq -S > a1
        ddisasm-deterministic a.out --json | jq -S > a2
        (diff -u a1 a2 || true) | tee $out
      '' + lib.optionalString (!stdenv.isDarwin) ''
        diff -q a1 a2
      ''
      );

  meta = {
    mainProgram = "ddisasm";
    homepage = "https://github.com/grammatech/ddisasm";
    description = "A fast and accurate disassembler.";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}

