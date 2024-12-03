{ lib
, alive2
, stdenv
, llvmPackages
, fetchFromGitHub
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2024-11-06";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "1ee0262b3da36b54cc6cffc94df7dcf4d0875f61";
    hash = "sha256-tUIMt3nmcdlBg9u6v3J+6yhs06zHkNCEkKx7pmgZ8J8=";
  };

  patches = [ ];
  CXXFLAGS = (prev.CXXFLAGS or "")
    + lib.optionalString (!stdenv.isDarwin) " -Wno-error=maybe-uninitialized";
})
