{ alive2
, fetchFromGitHub
, llvmPackages
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "unstable-2024-02-25";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "79097cc4b346f002a8eca8b4a343858e5fcf4bf8";
    hash = "sha256-cvta+2NZ2LzlcXwNiL/tKrA759TF+lSiwfzFfOCmvIo=";
  };

  patches = [ ];
  CXXFLAGS = prev.CXXFLAGS or "" + " -Wno-error=maybe-uninitialized";
})
