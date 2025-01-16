{ lib
, alive2-aslp
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2-aslp.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2025-01-16";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "c6e1e1a78fa5fabd54562a80fb534d525d0b7eaf";
    hash = "sha256-1bMkUO6YFoFGi/16vUKMSVV0zbO421BnlDQ+2178Fj4=";
  };

})
