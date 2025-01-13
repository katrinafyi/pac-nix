{ lib
, alive2-aslp
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2-aslp.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2025-01-10";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "a5642ad047a69dcf318a8c4396dc68f668b5d0a1";
    hash = "sha256-qW1w/M0pfHwRupd1J+PHe1rzEc+9kkXSuOyHmsBPgrE=";
  };

})
