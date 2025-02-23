{ lib
, alive2-aslp
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2-aslp.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2025-02-21";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "0bdad944cd0dbba45d669c328c44f585b3594f95";
    hash = "sha256-R6GPmyH9tXBKuOTdViKrtZ7d5m/nkz6ipXL318xZdN8=";
  };

})
