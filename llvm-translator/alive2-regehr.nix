{ lib
, alive2
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2024-12-16";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "52ff70645bcf4bf29b7b86a98a857b602fc1d0fa";
    hash = "sha256-yCnrtVj/5eovNVtU2llOLeIoUail9+HaBGuVIYSrkB0=";
  };

  patches = [ ];
  CXXFLAGS = (prev.CXXFLAGS or "")
    + lib.optionalString (!stdenv.isDarwin) " -Wno-error=maybe-uninitialized";
})
