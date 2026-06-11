{ lib
, alive2-aslp
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2-aslp.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2026-05-12";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "ab2fce5a2b96072373d2cc8629c4c76b6e9bf0ab";
    hash = "sha256-rbP1fJs85zL5dhHu/HgDh1nDmJnJX0UHBVYSWxOjfgM=";
  };

  meta = (prev.meta or {}) // { broken = true; };
})
