{ lib
, alive2-aslp
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2-aslp.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2025-05-26";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "2d5bac5c673c786daee8fe36fa578ba9f140aedb";
    hash = "sha256-I068NxjsbXNbfmlxbfqgef1XpqwD8f+ivpYapudDBhQ=";
  };

})
