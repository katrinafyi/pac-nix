{ lib
, alive2-aslp
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2-aslp.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2025-01-30";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "95158e86a76d9bbc7e3dbd0b056f2575a24d16ba";
    hash = "sha256-ZUq1rvFI2ZSWFOSkc8+OubZoO5bYgVHB2fugsU4Wl1Y=";
  };

})
