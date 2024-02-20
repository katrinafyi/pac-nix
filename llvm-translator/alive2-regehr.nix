{ alive2
, fetchFromGitHub
, llvmPackages
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "unstable-2024-02-20";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "6b7adba4f7d26a44ab9d51c773b397f6edbf058a";
    hash = "sha256-LBSshfPcBwODnN1wvQA7+OIwqU/PaVzPGc101Md1otU=";
  };

  patches = [ ];
  CXXFLAGS = prev.CXXFLAGS or "" + " -Wno-error=maybe-uninitialized";
})
