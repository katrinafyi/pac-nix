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
    rev = "e43612177f3bb8d4fa50fb5f8b55c87a5f7983a4";
    hash = "sha256-nqInupttDkm7Tml5ri/xurkH2xz+jmuWdXdYxDwHGvc=";
  };

  patches = [ ];
  CXXFLAGS = prev.CXXFLAGS or "" + " -Wno-error=maybe-uninitialized";
})
