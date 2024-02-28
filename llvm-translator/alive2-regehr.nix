{ alive2
, fetchFromGitHub
, llvmPackages
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "unstable-2024-02-28";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "89bac74d7b068a00419e269e33624f2e02e8a803";
    hash = "sha256-+o4LChvYOwW/XZzs9kyFKz+FugcLUCk9UIW+tJmbtyQ=";
  };

  patches = [ ];
  CXXFLAGS = prev.CXXFLAGS or "" + " -Wno-error=maybe-uninitialized";
})
