{ alive2
, llvmPackages
, fetchFromGitHub
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2024-08-01";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "a0b5f308c51b3f3cfb025ffe00f5fae02c03418a";
    hash = "sha256-CJkRC9j9Q3J5f+mYjGIpgfRhJQJiqbDc2tRIaftvC4Q=";
  };

  patches = [ ];
  CXXFLAGS = prev.CXXFLAGS or "" + " -Wno-error=maybe-uninitialized";
})
