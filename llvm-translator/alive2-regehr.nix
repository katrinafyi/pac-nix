{ lib
, alive2
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2024-12-17";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "7f3294b92ca39f7a46bf77574d3d9369ca00ada5";
    hash = "sha256-ymJWLtNNqHaoPU851lgujk32OuamV4deg2F8bOz2SSU=";
  };

  patches = [ ];
  CXXFLAGS = (prev.CXXFLAGS or "")
    + lib.optionalString (!stdenv.isDarwin) " -Wno-error=maybe-uninitialized";
})
