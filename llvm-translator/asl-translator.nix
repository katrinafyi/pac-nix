{ lib,
  fetchFromGitHub,
  ocaml,
  pkgs,
  ocamlPackages,
  llvmPackages_14,
  asli,
  z3
}:

let ocaml-llvm = ocamlPackages.llvm.override { libllvm = llvmPackages_14.libllvm; };
in ocamlPackages.buildDunePackage rec {
  pname = "asl-translator";
  version = "unstable-2023-09-18";

  buildInputs = [ z3 ];
  propagatedBuildInputs = [ asli ocaml-llvm ];

  src = fetchFromGitHub {
    owner = "UQ-PAC";
    repo = "llvm-translator";
    rev = "d86b20f98c0bbe445059b54812cbb15ecb4be67f";
    sha256 = "sha256-4mB+z/tnE6ghX3Kj0ZUbJHQeU5lz4fVOtADXgcjcRxg=";
  };
  sourceRoot = "source/asl-translator";

  meta = {
    homepage = "https://github.com/UQ-PAC/llvm-translator";
    description = "llvm-translator for comparison of lifter outputs (asl-translator component).";
    maintainers = [ "Kait Lam <k@rina.fyi>" ];
  };
}
