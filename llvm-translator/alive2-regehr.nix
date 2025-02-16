{ lib
, alive2-aslp
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2-aslp.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2025-02-14";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "cda56a42f8e5c1e6b1e1655eae17c5db74a7ddfa";
    hash = "sha256-9rDMfvM854JeU9l9Ju5NDN7ICuKc8p+ws2cvbaNuo2s=";
  };

})
