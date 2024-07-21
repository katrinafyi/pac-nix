{ alive2
, llvmPackages
, fetchFromGitHub
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2024-07-20";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "89f443e84d229ed2ccd160fbe7b652b9a4eb1de5";
    hash = "sha256-U63VU9H56w40efR3Que9+y4zLCsvJCnzKH03IP8Zs60=";
  };

  patches = [ ];
  CXXFLAGS = prev.CXXFLAGS or "" + " -Wno-error=maybe-uninitialized";
})
