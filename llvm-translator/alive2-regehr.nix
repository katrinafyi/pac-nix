{ alive2
, llvmPackages
, fetchFromGitHub
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "0-unstable-2024-08-06";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "bc6548ca97c22e368ec7bd40b1d8934f842ddd35";
    hash = "sha256-pdzHUEosm5FAqcQ5BHpg8bu2pEXbY/GPMz5sXs9HeT8=";
  };

  patches = [ ];
  CXXFLAGS = prev.CXXFLAGS or "" + " -Wno-error=maybe-uninitialized";
})
