{ lib
, alive2
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2024-12-22";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "95287e7b01b980fff900ba6d9b6f425bd71b133b";
    hash = "sha256-z4hprptm2I8CoYnztwYtdgWYdPQ55FD/drpzOcqh41w=";
  };

  patches = [ ];
  CXXFLAGS = (prev.CXXFLAGS or "")
    + lib.optionalString (!stdenv.isDarwin) " -Wno-error=maybe-uninitialized";
})
