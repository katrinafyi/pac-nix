{ lib
, alive2-aslp
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2-aslp.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2025-01-25";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "74584a64a6db198eec6c84818f2b6d4e0173fd5f";
    hash = "sha256-00bx+D8t5yKCho70mLVECRMT4BSsAz8I7PEDRKOy7ek=";
  };

})
