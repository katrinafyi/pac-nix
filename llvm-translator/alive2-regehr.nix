{ lib
, alive2-aslp
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2-aslp.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2025-01-14";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "78657f9693767952ffad6a9901421dd820386b41";
    hash = "sha256-Sp6+H5SP6gTEY5z0D+nykW4hvMUBGc+RdD5kDTv3tSM=";
  };

})
