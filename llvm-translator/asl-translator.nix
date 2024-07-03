{ lib
, buildDunePackage
, fetchFromGitHub
, asli
, llvm
}:

buildDunePackage rec {
  pname = "asl-translator";
  version = "0-unstable-2023-09-25";

  buildInputs = [ asli llvm ];

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "llvm-translator";
    rev = "2110ff718c2f3bd8f428653b3f6ce471eb399adb";
    sha256 = "sha256-zIp8HxgLT/5KTSNRXFJo6V38DpMHEMg1aB4ByGEQy8I=";
  };
  sourceRoot = "source/asl-translator";

  meta = {
    homepage = "https://github.com/UQ-PAC/llvm-translator";
    description = "llvm-translator for comparison of lifter outputs (asl-translator component).";
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}
