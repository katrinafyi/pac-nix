{ alive2
, llvmPackages
, fetchFromGitHub
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2024-08-08";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "7d8cbffd97a10f14489384ddd7a5aea9e4fa8523";
    hash = "sha256-anvsnqLaa1HZeEdi7EvOp1QJLOxtyOqon3bdiTCYY+s=";
  };

  patches = [ ];
  CXXFLAGS = prev.CXXFLAGS or "" + " -Wno-error=maybe-uninitialized";
})
