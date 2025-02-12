{ lib
, alive2-aslp
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2-aslp.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2025-02-11";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "031f02fe21bfa2925a8de6f33900ba176ee47db9";
    hash = "sha256-VFwHJxBBvm9XzR0roNawa93LMFQ8lmTAfRQPjYCoCNc=";
  };

})
