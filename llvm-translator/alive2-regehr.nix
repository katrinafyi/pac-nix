{ alive2
, fetchFromGitHub
, llvmPackages
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "unstable-2024-03-04";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "12811e2dfe6c1988ee5527934ee4a8a7ca027213";
    hash = "sha256-+LfVA5+hIY4skXM/4EzkOvGDMhkkVvsDff0Ht7g91FY=";
  };

  patches = [ ];
  CXXFLAGS = prev.CXXFLAGS or "" + " -Wno-error=maybe-uninitialized";
})
