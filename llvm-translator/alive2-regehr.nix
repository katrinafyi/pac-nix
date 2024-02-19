{ alive2
, fetchFromGitHub
, llvmPackages
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "unstable-2024-02-19";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "9047b9ef3e791c4637f9b350f4cc7b8e6ec5f090";
    hash = "sha256-rwYfaPqOmNPg46V0dPcEAeANEk+pDADO+WqnbcTA6Zg=";
  };

  patches = [ ];
  CXXFLAGS = prev.CXXFLAGS or "" + " -Wno-error=maybe-uninitialized";
})
