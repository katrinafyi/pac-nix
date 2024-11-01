{ lib
, alive2
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2024-10-26";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "164b04a74920d926d3d5e6e11ee297eaec841e64";
    hash = "sha256-rrd9cuOAh7fYOJpZ829+eQ/y3ha6LEi+f+PvVWH0z9o=";
  };

  patches = [ ];
  CXXFLAGS = (prev.CXXFLAGS or "")
    + lib.optionalString (!stdenv.isDarwin) " -Wno-error=maybe-uninitialized";
})
