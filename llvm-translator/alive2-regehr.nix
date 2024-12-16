{ lib
, alive2
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2024-12-15";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "e13bc8b6c4100b70bf3bab7a71de734d0b6fabd7";
    hash = "sha256-LmHRTEqTFQBVTrein+X+PtOp7Mqk41nnZFF4vRIH/8U=";
  };

  patches = [ ];
  CXXFLAGS = (prev.CXXFLAGS or "")
    + lib.optionalString (!stdenv.isDarwin) " -Wno-error=maybe-uninitialized";
})
