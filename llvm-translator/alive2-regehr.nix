{ alive2
, fetchFromGitHub
, llvmPackages
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "unstable-2024-02-21";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "69bd9dfde6c9ae9e23b4635824a7fa0035aa0ce8";
    hash = "sha256-V7g1Cbtqvda7MNsTkYDDUQw2ps/7MmpdSEULVzaqp2s=";
  };

  patches = [ ];
  CXXFLAGS = prev.CXXFLAGS or "" + " -Wno-error=maybe-uninitialized";
})
