{ alive2
, fetchFromGitHub
, llvmPackages
}:

(alive2.override { inherit llvmPackages; }).overrideAttrs (prev: {
  pname = "alive2-regehr";
  version = "unstable-2024-02-22";

  src = fetchFromGitHub {
    owner = "regehr";
    repo = "alive2";
    rev = "f04ffa8d14cb42a6886786b54869633f8674e39d";
    hash = "sha256-Z9DZnpAYrS75ichO+Xwx3mu7m+Tl3CXlgq2ArVw/BY4=";
  };

  patches = [ ];
  CXXFLAGS = prev.CXXFLAGS or "" + " -Wno-error=maybe-uninitialized";
})
