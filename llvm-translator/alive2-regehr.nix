{ alive2
, llvmPackages
, fetchFromGitHub
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2024-07-24";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "a7a4c2b3ffd6fa1467cea224d0db5a4b965d1b0c";
    hash = "sha256-noLVQ+6rcCjqxA9MMTrhrQ6Uxb8/EXqKVFk2hjNo790=";
  };

  patches = [ ];
  CXXFLAGS = prev.CXXFLAGS or "" + " -Wno-error=maybe-uninitialized";
})
