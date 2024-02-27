{ alive2
, fetchFromGitHub
, llvmPackages
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "unstable-2024-02-27";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "b0dee1b12a68548ee69d78d6709334e5523183ff";
    hash = "sha256-ghXYqVUE33mfNk583FfiAVSIaJnmEz+csiLdbf2gObE=";
  };

  patches = [ ];
  CXXFLAGS = prev.CXXFLAGS or "" + " -Wno-error=maybe-uninitialized";
})
