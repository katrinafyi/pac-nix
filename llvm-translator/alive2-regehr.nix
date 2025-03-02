{ lib
, alive2-aslp
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2-aslp.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2025-02-28";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "d0a6b4c8002e437cc6edbd4ccdac5c722cbc9c18";
    hash = "sha256-WW41gM4Uez0C/YgNqrzww3hejiqSCifBBKrgW8aqEi8=";
  };

})
