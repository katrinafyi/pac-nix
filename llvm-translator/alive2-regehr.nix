{ alive2
, llvmPackages
, fetchFromGitHub
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2024-07-16";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "549fe5d5452af964bb7c48dcf178de5e436d7151";
    hash = "sha256-JrD+Z5WrI0QRyHJEAlmB4FTavRnov58DX4Lgbz35EQ8=";
  };

  patches = [ ];
  CXXFLAGS = prev.CXXFLAGS or "" + " -Wno-error=maybe-uninitialized";
})
